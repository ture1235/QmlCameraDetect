import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1232
    height: 800
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint
    color: "transparent"

    property real goldenRatio: 1.618
    property real widthRatio: 2.875  // width ratio

    Rectangle {
        id: windowBackground
        anchors.fill: parent
        color: "#000000"
        // color: "red"
        radius: mainWindow.width * 0.03

        Rectangle {
            id: left_mask
            anchors.left: parent.left
            width: mainWindow.width * 0.06
            height: parent.height
            radius: mainWindow.width * 0.03
            color: "#1C1C1E"
        }

        Rectangle {
            id: right_mask
            x: left_mask.radius
            y: 0
            width: mainWindow.width * 0.03
            height: parent.height
            color: "#1C1C1E"
        }

        RowLayout {
            anchors.fill: parent
            // anchors.margins: grid.ratio  // 保持原间距逻辑
            anchors.leftMargin: 0
            anchors.topMargin: grid.ratio
            anchors.bottomMargin: grid.ratio
            anchors.rightMargin: grid.ratio
            spacing: grid.ratio
            // =============== 左侧功能区（宽度占比 1）===============
            // ColumnLayout {

            //     id: sidePanel

            //     Layout.fillHeight: true
            //     Layout.fillWidth: true
            //     Layout.preferredWidth: 1  // ← 关键：比例 1

            Rectangle{
                Layout.preferredWidth: 2  // ← 关键：比例 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1C1C1E"
                radius: mainWindow.width * 0.06
                // 🔘 关闭按钮（顶部对齐）
                // 👇 可滚动（未来加很多按钮时用）
                // ScrollView {
                //     Layout.fillWidth: true
                //     Layout.fillHeight: true
                //     contentWidth: -1  // 自适应
                // }
                SidePannel{
                    // id: sidapannel
                    // anchors.fill: parent
                }
            }


                // 剩余空间撑开（让按钮靠上）

            // }

            // =============== 右侧主内容区（宽度占比 8）===============
            GridLayout {
                id: grid

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 31  // ← 关键：比例 1
                columns: 2
                rows: 2
                property real ratio: mainWindow.width * 0.015
                // anchors.margins: ratio
                // 设置间距为0
                columnSpacing: ratio
                rowSpacing: ratio

                // 左上角：黄金比例宽 × 黄金比例高
                Rectangle {
                    id: topLeft
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: parent.columnSpacing
                    color: "#1C1C1E"
                    // 宽度比例：黄金比例部分
                    Layout.preferredWidth: 2.875
                    // 高度比例：黄金比例部分
                    Layout.preferredHeight: goldenRatio

                    // Image {
                    //     source: "file:///home/dutrue/shared/tt.png"
                    //     fillMode: Image.PreserveAspectFit
                    //     anchors.fill: parent
                    //     anchors.margins: 5
                    // }
                    // VideoDetectionOverlay{
                    //     anchors.fill: parent
                    // }
                    DeclarativeCamera{
                        id: cameraShow
                        objectName: "cameraShow"
                        anchors.fill: parent
                        radiusPartWidth: parent.radius
                        Connections {
                            target: cameraShow.overLay.mouseArea
                            function onPositionChanged(mouse) {
                                var vidPoint = cameraShow.overLay.screenToVideo(mouse.x, mouse.y)
                                if (vidPoint.x >= 0 && vidPoint.y >= 0) {
                                    modeSwitchBar.currentPosition.text = Math.round(vidPoint.x) + ", " + Math.round(vidPoint.y)
                                }
                            }
                        }
                        Connections {
                            target: cameraShow.overLay
                            function onDetectionDataChanged() {
                                modeSwitchBar.targetNum.text = cameraShow.overLay.detectionData.length
                            }
                            function onFrameReceived() {
                                // 更新模式切换栏的帧率
                                if (modeSwitchBar) {
                                    modeSwitchBar.updateFrameRate();
                                }
                            }
                        }
                        
                        

                        // anchors.centerIn: parent
                        // width: parent.width - parent.radius
                        // height: parent.height
                    }

                }

                // 右上角：剩余宽(1) × 黄金比例高
                Rectangle {
                    id: topRight
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: goldenRatio

                    radius: parent.columnSpacing
                    color: "#1C1C1E"
                    // Text {
                    //     text: "右上角\n剩余宽度: "
                    //     anchors.centerIn: parent
                    //     font.pixelSize: 16
                    //     horizontalAlignment: Text.AlignHCenter
                    // }
                    DetectInfo{
                        id: detectInfo
                        anchors.fill: parent
                        Connections {
                            target: detectInfo
                            function onToggleDetect() {
                                if (typeof frameHandler !== 'undefined' && frameHandler) {
                                    frameHandler.toggle_connection();
                                    
                                }
                            }
                        }
                    }

                }

                // 左下角：黄金比例宽 × 剩余高(1)
                Rectangle {
                    id: bottomLeft
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2.875
                    Layout.preferredHeight: 1

                    radius: parent.columnSpacing
                    color: "#1C1C1E"  // 恢复为正常颜色

                    // 使用新的模式切换栏
                    ModeSwitchBar {
                        id: modeSwitchBar
                        anchors.fill: parent
                        
                        // 绑定属性
                        captureSession: cameraShow.insideCaptureSession
                        currentMode: cameraShow.state === "VideoCapture" ? "video" : "photo"
                        previewAvailable: {
                            if (cameraShow.state === "PhotoCapture") {
                                return cameraShow.insideCaptureSession.imageCapture.preview.length !== 0
                            } else if (cameraShow.state === "VideoCapture") {
                                return cameraShow.insideCaptureSession.recorder.actualLocation.toString() !== ""
                            }
                            return false
                        }
                        cameraFormats: cameraShow.cameraFormats  // 这是绑定格式，在combox里面使用
                        // 读取一次currentCameraFormat不绑定
                        currentCameraFormat: cameraShow.currentCameraFormat
                        // 连接相机格式更新信号
                        // Connections {
                        //     target: cameraShow.insideCaptureSession
                        //     function onCameraChanged() {
                        //         // 当相机格式更新时，触发 ComboBox 更新
                        //         console.log("Camera changed 11111111111111111111111111111111111");
                        //         if (modeSwitchBar.formatComboBox) {
                        //             modeSwitchBar.formatComboBox.updateModel();
                        //         }
                        //         // 更新listselector的model
                        //         console.log("update selector model")
                        //         if (modeSwitchBar.listSelector) {
                        //             var newData = []
                        //             for (var i = 0; i < modeSwitchBar.cameraFormats.length; i++) {
                        //                 var resolution = modeSwitchBar.cameraFormats[i].resolution.width + ":" + modeSwitchBar.cameraFormats[i].resolution.height
                        //                 newData.push({
                        //                     name: resolution,
                        //                     value: i
                        //                 })
                        //             }
                        //             modeSwitchBar.listSelector.refreshModel(newData)
                        //         }
                                
                        //     }
                        // }

                        // 连接信号
                        onPhotoModeSelected: {
                            cameraShow.state = "PhotoCapture"
                        }
                        
                        onVideoModeSelected: {
                            cameraShow.state = "VideoCapture"
                        }
                        
                        onPreviewSelected: {
                            if (cameraShow.state === "PhotoCapture") {
                                cameraShow.state = "PhotoPreview"
                            } else if (cameraShow.state === "VideoCapture") {
                                cameraShow.state = "VideoPreview"
                            }
                        }
                        
                        onCaptureRequested: {
                            cameraShow.insideCaptureSession.imageCapture.captureToFile("")
                        }
                        
                        onRecordRequested: {
                            cameraShow.insideCaptureSession.recorder.record()
                        }
                        
                        onStopRequested: {
                            cameraShow.insideCaptureSession.recorder.stop()
                        }
                        
                        // onToggleDetection: {
                        //     // 调用 Python 的 FrameHandler 切换检测状态
                        //     if (typeof frameHandler !== 'undefined' && frameHandler) {
                        //         frameHandler.toggle_connection();
                        //         // 更新按钮状态
                        //         modeSwitchBar.isDetectionEnabled = frameHandler.get_connection_status();
                        //         // console.log(cameraShow.currentCameraFormat)
                        //     }
                        // }

                        onTogglePreviewResolution: function (format) {
                            //cameraShow.insideCaptureSession.camera.cameraDevice.setPreviewResolution(modeSwitchBar.previewResolution)
                            // for (var i = 0; i < cameraShow.insideCaptureSession.camera.cameraDevice.videoFormats.length; i++) {
                            //     var format = cameraShow.insideCaptureSession.camera.cameraDevice.videoFormats[i];
                            //     console.log("分辨率:", format.resolution.width, "x", format.resolution.height, "帧率:", format.maxFrameRate, "像素格式:", format.pixelFormat);
                            //     // if (i === 2){
                            //     //     // 设置分辨率
                            //     //     cameraShow.insideCaptureSession.camera.cameraFormat = format;
                            //     //     console.log(cameraShow.insideCaptureSession.camera.cameraFormat.resolution);
                            //     // }
                            console.log("kaishi设置分辨率:");
                            cameraShow.insideCaptureSession.camera.cameraFormat = format;
                            // }
                            console.log(cameraShow.insideCaptureSession.camera.cameraFormat.resolution)
                        }
                    }
                }

                // 右下角：剩余宽(1) × 剩余高(1)
                Rectangle {
                    id: bottomRight
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 1

                    radius: parent.columnSpacing
                    color: "#1C1C1E"
                    Text {
                        text: "右下角\n剩余宽度: "
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        // 🖱️ 标题栏（需调整 anchors 避免被 sidePanel 遮挡）
        Rectangle {
            id: titleBar
            width: mainWindow.width * 0.94
            height: grid.ratio
            color: "transparent"
            // opacity: 0.7
            // 🔑 关键：标题栏要横跨整个 windowBackground，不是 RowLayout
            anchors.top: parent.top
            // anchors.left: parent.left
            // anchors.right: parent.right
            anchors.horizontalCenter: parent.horizontalCenter
            // gradient: Gradient {
            //     orientation: Gradient.Horizontal
            //     GradientStop { position: 0.0; color: "gray" }      // 左边
            //     GradientStop { position: 0.5; color: "#404040" }   // 中间
            //     GradientStop { position: 1.0; color: "black" }     // 右边
            // }

            MouseArea {
                anchors.fill: parent
                onPressed: mainWindow.startSystemMove()
                onDoubleClicked: {
                    if (mainWindow.visibility === Window.Maximized) {
                        mainWindow.showNormal()
                    } else {
                        mainWindow.showMaximized()
                    }
                }
                onClicked: {
                    console.log(topLeft.width, topLeft.height)
                }
            }
        }
    }

    // RadiusRemainedPart{}
}
