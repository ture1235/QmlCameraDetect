// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtMultimedia

Rectangle {
    id : cameraUI

    // width: 800
    // height: 480

    color: "transparent"
    state: "PhotoCapture"
   
    // qt支持的视频格式enum
    enum VideoFrameFormat {
        Invalid = 0,
        ARGB8888,
        ARGB8888_Premultiplied,
        XRGB8888,
        BGRA8888,
        BGRA8888_Premultiplied,
        ABGR8888,
        XBGR8888,
        RGBA8888,
        BGRX8888,
        RGBX8888,
        AYUV,
        AYUV_Premultiplied,
        YUV420P,
        YUV422P,
        YV12,
        UYVY,
        YUYV,
        NV12,
        NV21,
        IMC1,
        IMC2,
        IMC3,
        IMC4,
        Y8,
        Y16,
        NV16,
        NV24,
        YV24,
        YUV444,
        YUV411,
        MJPEG,
        M210,
        UYVY,
        YUYV,
        NV12,
        NV21,
        IMC1,
        IMC2,
        IMC3,
        IMC4,
        P010,
        P016,
        Y8,
        Y16,
        JPEG,
        SamplerExternalOES,
        SamplerRect,
        YUV420P10
    }

    // 摄像头格式list
    property var cameraFormats: []
    property var currentCameraFormat: null
    property var defaultCameraFormat: detectionOverlay.defaultCameraFormat // 默认摄像头格式,可以通过c++ 或者python去获取，qml里面不太能使用videosink对象
    property string platformScreen: ""
    property int buttonsPanelLandscapeWidth: cameraUI.width/2
    property int buttonsPanelPortraitHeight: cameraUI.height/3
    property real radiusPartWidth: 0
    property alias insideCaptureSession: captureSession
    property alias statusItem: controlLayout
    property alias overLay: detectionOverlay

    
    function updateAllCameraFormats() {
        if (camera && camera.cameraDevice && camera.cameraDevice.videoFormats) {
            var readedFormats = camera.cameraDevice.videoFormats;
            cameraFormats = [];
            //先增加一个默认格式，首次打开未设置的格式
            cameraFormats.push(camera.cameraFormat);
            for (var i = 0; i < readedFormats.length; i++) {
                var format = readedFormats[i];
                // console.log("读取到支持的视视频格式:", format, "分辨率:", format.resolution, "最大帧率:", format.maxFrameRate);
                // 创建包含分辨率信息的对象
                // var formatInfo = {
                //     format: format,
                //     // 直接使用像素格式的数值
                //     pixel_format: format.pixelFormat
                // };
                // 只添加mjpeg格式的，其他格式支持，但目前不是很了解，先注释掉，这里的29表示mjpeg格式
                if (format.pixelFormat === 29 && format.resolution.width > 639 && format.resolution.height > 479 && format.maxFrameRate === 30) {
                    cameraFormats.push(format);
                }
                // TODO 添加其他格式的判断
                // cameraFormats.push(format);
            }
        }
    }



    states: [
        State {
            name: "PhotoCapture"
            StateChangeScript {
                script: {
                    camera.start()
                    cameraUI.updateAllCameraFormats()
                    cameraUI.currentCameraFormat = camera.cameraFormat
                }
            }
        },
        State {
            name: "PhotoPreview"
        },
        State {
            name: "VideoCapture"
            StateChangeScript {
                script: {
                    camera.start()
                    cameraUI.updateAllCameraFormats()
                    cameraUI.currentCameraFormat = camera.cameraFormat

                }
            }
        },
        State {
            name: "VideoPreview"
            StateChangeScript {
                script: {
                    camera.stop()
                }
            }
        }
    ]

    CaptureSession {
        id: captureSession
        objectName: "captureSession"  // 让 Python 能找到这个对象
        camera: Camera {
            id: camera

        }
        imageCapture: ImageCapture {
            id: imageCapture
        }

        recorder: MediaRecorder {
            id: recorder
            // mediaFormat {
            //     fileFormat: MediaFormat.WebM
            //     audioCodec: MediaFormat.AudioCodec.Vorbis
            //     videoCodec: MediaFormat.VideoCodec.VP8
            // }
            quality: MediaRecorder.NormalQuality
            videoFrameRate: 30
            videoBitRate: 2000000
            videoResolution: Qt.size(1280, 720)
        }
        // 注意: 现在使用 detectionOverlay 作为 videoOutput
        videoOutput: detectionOverlay.videoOutput

        onCameraChanged: {
            console.log("Camera changed to:", camera)
            updateAllCameraFormats()
        }
    }




    PhotoPreview {
        id : photoPreview
        anchors.fill : parent
        onClosed: cameraUI.state = "PhotoCapture"
        visible: (cameraUI.state === "PhotoPreview")
        focus: visible
        source: imageCapture.preview
    }

    VideoPreview {
        id : videoPreview
        anchors.fill : parent
        onClosed: cameraUI.state = "VideoCapture"
        visible: (cameraUI.state === "VideoPreview")
        focus: visible

        //don't load recorded video if preview is invisible
        source: visible ? recorder.actualLocation : ""
    }

    // 使用 CameraDetectionOverlay 替代原来的 VideoOutput
    CameraDetectionOverlay {
        id: detectionOverlay
        objectName: "detectionOverlay"  // 让 Python 能找到
        anchors.fill: parent
        visible: ((cameraUI.state === "PhotoCapture") || (cameraUI.state === "VideoCapture"))
    }

    Connections {
        target: detectionOverlay
        function onDefaultCameraFormatGot() {
            console.log("收到默认格式传来的信号了")
            // 由于这里只支持了mjpeg格式，如果默认为其他格式，我们还是添加一个在cameraFormats里面大小一样的格式放在首位
            for (var i = 1; i < cameraFormats.length; i++) {
                if (cameraFormats[i].resolution.width === defaultCameraFormat.width && cameraFormats[i].resolution.height === defaultCameraFormat.height) {
                    defaultCameraFormat = cameraFormats[i]
                    console.log("找到默认格式了大小了")
                    break
                }
            }
            cameraFormats[0] = defaultCameraFormat
        }
    }

    Item {
        id: controlLayout

        readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
        readonly property bool isLandscape: Screen.desktopAvailableWidth >= Screen.desktopAvailableHeight
        property int buttonsWidth: state === "MobilePortrait" ? Screen.desktopAvailableWidth / 3.4 : 114

        states: [
            State {
                name: "MobileLandscape"
                when: controlLayout.isMobile && controlLayout.isLandscape
            },
            State {
                name: "MobilePortrait"
                when: controlLayout.isMobile && !controlLayout.isLandscape
            },
            State {
                name: "Other"
                when: !controlLayout.isMobile
            }
        ]

        onStateChanged: {
            console.log("State: " + controlLayout.state)
        }
    }

    RadiusRemainedPart{
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: radiusPartWidth
    }

    RadiusRemainedPart{
        width: radiusPartWidth
        anchors.right: parent.right
        anchors.top: parent.top
        direction: RadiusRemainedPart.TopRight
    }

    RadiusRemainedPart{
        anchors.left: parent.left
        anchors.top: parent.top
        width: radiusPartWidth
        direction: RadiusRemainedPart.TopLeft
    }

    RadiusRemainedPart{
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: radiusPartWidth
        direction: RadiusRemainedPart.BottomLeft
    }

}
