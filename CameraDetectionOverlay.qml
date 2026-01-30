// CameraDetectionOverlay.qml - 摄像头实时流 + 检测框覆盖层
import QtQuick
import QtQuick.Controls
import QtMultimedia

Rectangle {
    id: root
    color: "transparent"
    
    // 信号
    signal defaultCameraFormatGot
    signal frameReceived  // 新增：当视频帧到达时发出信号
    // signal dataChanged (var num)

    // 属性
    property var detectionData: []  // 检测数据数组
    property color boxColor: "red"  // 矩形框颜色
    property color labelColor: "white"  // 标签文字颜色
    property int labelFontSize: 12
    property bool showLabels: true
    property real overlayOpacity: 1  // 半透明层透明度
    
    // 暴露内部的 VideoOutput,供 CaptureSession 使用
    property alias videoOutput: videoOutput
    
    // 暴露 VideoOutput 的 videoSink 给 Python (通过 objectName 查找)
    readonly property var videoSink: videoOutput.videoSink

    // export MouseArea to another area recieve
    property alias mouseArea: mouseArea
    
    // 计算属性:获取视频的实际显示区域
    property rect videoDisplayRect: Qt.rect(0, 0, 0, 0)
    
    property var defaultCameraFormat: null
    //设置当前视频帧的格式
    function setVideoDefaultFormat(format) {
        console.log("QML: 设置默认视频格式:", format)
        defaultCameraFormat = format
        defaultCameraFormatGot()
    }

    function updateVideoDisplayRect() {
        var vidX = 0
        var vidY = 0
        var vidWidth = videoOutput.width
        var vidHeight = videoOutput.height
        
        // VideoOutput 默认是 PreserveAspectFit,计算实际显示区域
        // 注意: VideoOutput 没有 paintedWidth,我们需要手动计算
        if (videoOutput.sourceRect.width > 0 && videoOutput.sourceRect.height > 0) {
            var containerRatio = videoOutput.width / videoOutput.height
            var videoRatio = videoOutput.sourceRect.width / videoOutput.sourceRect.height
            
            if (videoRatio > containerRatio) {
                // 视频更宽,左右撑满,上下留黑边
                vidWidth = videoOutput.width
                vidHeight = videoOutput.width / videoRatio
                vidX = 0
                vidY = (videoOutput.height - vidHeight) / 2
            } else {
                // 视频更高,上下撑满,左右留黑边
                vidHeight = videoOutput.height
                vidWidth = videoOutput.height * videoRatio
                vidX = (videoOutput.width - vidWidth) / 2
                vidY = 0
            }
        }
        
        videoDisplayRect = Qt.rect(vidX, vidY, vidWidth, vidHeight)
    }
    
    // 更新videoformat
    

    // 清除所有检测框
    function clearAll() {
        detectionData = []
        canvas.requestPaint()
    }
    
    // 添加检测数据
    function addDetection(detection) {
        var newData = detectionData.slice()
        newData.push(detection)
        detectionData = newData
        canvas.requestPaint()
    }
    
    // 批量设置检测数据
    function setDetections(detections) {
        // for (var i = 0; i < detections.length; i++) {
        //     console.log("QML: 设置检测数据:", detections[i].x1, detections[i].y1, detections[i].x2, detections[i].y2)
        // }
        // console.log("QML: 设置检测数据:", detections)
        detectionData = detections
        canvas.requestPaint()
    }
    
    // 清除检测数据
    function clearDetections() {
        detectionData = []
        canvas.requestPaint()
    }
    
    // 检查坐标是否在视频显示区域内
    function isPointInVideo(x, y) {
        return x >= videoDisplayRect.x &&
               x <= videoDisplayRect.x + videoDisplayRect.width &&
               y >= videoDisplayRect.y &&
               y <= videoDisplayRect.y + videoDisplayRect.height
    }
    
    // 坐标转换:从视频原始坐标转换为屏幕坐标
    function videoToScreen(videoX, videoY) {
        if (videoOutput.sourceRect.width <= 0 || videoOutput.sourceRect.height <= 0) {
            return Qt.point(0, 0)
        }
        
        var scaleX = videoDisplayRect.width / videoOutput.sourceRect.width
        var scaleY = videoDisplayRect.height / videoOutput.sourceRect.height
        
        return Qt.point(
            videoDisplayRect.x + videoX * scaleX,
            videoDisplayRect.y + videoY * scaleY
        )
    }
    
    // 坐标转换:从屏幕坐标转换为视频原始坐标
    function screenToVideo(screenX, screenY) {
        if (!isPointInVideo(screenX, screenY)) {
            return Qt.point(-1, -1)
        }
        
        if (videoOutput.sourceRect.width <= 0 || videoOutput.sourceRect.height <= 0) {
            return Qt.point(-1, -1)
        }
        
        var scaleX = videoDisplayRect.width / videoOutput.sourceRect.width
        var scaleY = videoDisplayRect.height / videoOutput.sourceRect.height
        
        return Qt.point(
            (screenX - videoDisplayRect.x) / scaleX,
            (screenY - videoDisplayRect.y) / scaleY
        )
    }
    
    // 主视频显示区域
    VideoOutput {
        id: videoOutput
        anchors.fill: parent

        /* TODO：当camera实现图像输出时，展示的视频流时一个默认的格式，当试图获取camera.cameraFormat的格式时，会返回一个默认的invalid格式,暂时无法获取，
        当我在qml里面获取VideoOutput.videoSink的时候，返回的时一个QQuickVideoSink对象，但是这个对象没有cameraFormat属性，所以无法获取camera.cameraFormat的格式，
        所以暂时无法获取视频的格式，只能使用VideoOutput.videoSink.videoSize -> 返回的是 QSize()
        但是，我在python侧访问的时候，通过root.findChild(QObject, "cameraShow") -> camera_show.findChild(QObject, "detectionOverlay")在获取到videoSink的时候 ，返回的就是QVideoSink
        QVideoSink就能获取到的帧onFrameChanged()的时候传出frame出来 ，能通过  frame.surfaceFormat().pixelFormat()获取到当前的界面格式，考虑是否需要通过python传出
        */
    //     Component.onCompleted: {
    //         firstFrameFormatGetter.enabled = true
    //     }

    //     property bool hassetFirstFrameFormat: false
    }
    
    // Connections {
    //     id: firstFrameFormatGetter
    //     target: videoOutput.videoSink
    //     enabled: false
    //     function onVideoFrameChanged (){
    //         // var frame = videoOutput.videoSink.videoFrame
    //         // var sink = videoOutput.videoSink
    //         // console.log("=== 探索 QQuickVideoSink ===");
    //         // console.log("对象类型:", typeof sink);
    //         // console.log("对象原型:", Object.getPrototypeOf(sink));
            
    //         // // 列出所有属性名
    //         // for (var prop in sink) {
    //         //     console.log(prop, ":", sink[prop]);
    //         // }
            
    //         // // 或者只列出函数
    //         // console.log("=== 函数列表 ===");
    //         // for (var prop in sink) {
    //         //     if (typeof sink[prop] === 'function') {
    //         //         console.log(prop);
    //         //     }
    //         // }
    //         // console.log("QML: 视频帧格式:", frame)
    //     }
    // }
    // 半透明覆盖层 - 覆盖整个父组件
    Item {
        id: overlay
        anchors.fill: parent
        
        // 绘制Canvas
        Canvas {
            id: canvas
            anchors.fill: parent
            renderTarget: Canvas.FramebufferObject
            renderStrategy: Canvas.Cooperative
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, canvas.width, canvas.height)
                
                if (detectionData.length === 0) return
                
                // // 更新视频显示区域                // root.updateVideoDisplayRect()
                
                var vidWidth = videoDisplayRect.width
                var vidHeight = videoDisplayRect.height
                var srcWidth = videoOutput.sourceRect.width
                var srcHeight = videoOutput.sourceRect.height
                var vidX = videoDisplayRect.x
                var vidY = videoDisplayRect.y
                
                // 如果视频没有加载或显示区域无效,直接返回
                if (vidWidth <= 0 || vidHeight <= 0 || srcWidth <= 0 || srcHeight <= 0) {
                    return
                }
                
                // 计算缩放比例
                var scaleX = vidWidth / srcWidth
                var scaleY = vidHeight / srcHeight
                
                // 设置全局透明度
                ctx.globalAlpha = overlayOpacity
                
                // 绘制所有检测结果
                for (var i = 0; i < detectionData.length; i++) {
                    var detection = detectionData[i]
                    
                    // 提取检测数据
                    var x1 = detection.x1 || 0
                    var y1 = detection.y1 || 0
                    var x2 = detection.x2 || 0
                    var y2 = detection.y2 || 0
                    var label = detection.label || ""
                    var confidence = detection.confidence || 0
                    var color = detection.color || root.boxColor
                    
                    // 计算在屏幕上的坐标
                    var screenX1 = vidX + x1 * scaleX
                    var screenY1 = vidY + y1 * scaleY
                    var screenX2 = vidX + x2 * scaleX
                    var screenY2 = vidY + y2 * scaleY
                    
                    // 确保坐标在视频显示区域内
                    if (screenX1 < vidX) screenX1 = vidX
                    if (screenY1 < vidY) screenY1 = vidY
                    if (screenX2 > vidX + vidWidth) {
                        screenX2 = vidX + vidWidth
                    }
                    if (screenY2 > vidY + vidHeight) {
                        screenY2 = vidY + vidHeight
                    }
                    
                    var screenWidth = screenX2 - screenX1
                    var screenHeight = screenY2 - screenY1
                    // 如果宽度或高度无效,跳过
                    if (screenWidth <= 0 || screenHeight <= 0) {
                        continue
                    }
                    

                    // 绘制矩形框
                    ctx.strokeStyle = color
                    ctx.lineWidth = 6
                    ctx.setLineDash([])
                    ctx.strokeRect(screenX1, screenY1, screenWidth, screenHeight)
                    
                    // 绘制标签
                    if (root.showLabels && label) {
                        ctx.font = root.labelFontSize + "px sans-serif"
                        var text = label
                        if (confidence > 0) {
                            text += " " + confidence
                        }
                        
                        var textWidth = ctx.measureText(text).width
                        var textHeight = root.labelFontSize
                        
                        // 计算标签位置
                        var labelX = screenX1
                        var labelY = screenY1 - textHeight - 4
                        
                        // 如果标签超出顶部,放在框内底部
                        if (labelY < vidY) {
                            labelY = screenY1 + screenHeight
                        }
                        
                        // 如果标签超出右侧,向左移动
                        if (labelX + textWidth + 8 > vidX + vidWidth) {
                            labelX = vidX + vidWidth - textWidth - 8
                        }
                        
                        // 绘制标签背景
                        ctx.fillStyle = Qt.rgba(0, 0, 0, 0.7)
                        ctx.fillRect(labelX, labelY, textWidth + 8, textHeight + 4)
                        
                        // 标签文字
                        ctx.fillStyle = root.labelColor
                        ctx.fillText(text, labelX + 4, labelY + textHeight)
                    }
                }
            }
        }
    }
    
    // 坐标信息显示
    Text {
        id: coordInfo
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 5
        text: detectionData.length > 0 ?
              "检测到 " + detectionData.length + " 个目标" :
              "无检测目标"
        color: "white"
        font.pixelSize: 12
        style: Text.Outline
        styleColor: "black"
    }
    
    // 鼠标交互区域
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        // onClicked: function(mouse) {
        //     // 点击添加测试检测框
        //     var vidPoint = screenToVideo(mouse.x, mouse.y)
            
        //     if (vidPoint.x >= 0 && vidPoint.y >= 0) {
        //         var newDetection = {
        //             x1: vidPoint.x - 50,
        //             y1: vidPoint.y - 50,
        //             x2: vidPoint.x + 100,
        //             y2: vidPoint.y + 100,
        //             label: "测试目标",
        //             confidence: 0.85 + Math.random() * 0.15
        //         }
                
        //         addDetection(newDetection)
        //     }
        // }
        
        // onPositionChanged: function(mouse) {
        //     // 显示鼠标位置的视频坐标
        //     var vidPoint = screenToVideo(mouse.x, mouse.y)
        //     if (vidPoint.x >= 0 && vidPoint.y >= 0) {
        //         coordInfo.text = "视频坐标: (" + Math.round(vidPoint.x) + ", " + Math.round(vidPoint.y) + ")"
        //     } /*else {
        //         coordInfo.text = detectionData.length > 0 ?
        //             "检测到 " + detectionData.length + " 个目标" :
        //             "无检测目标"
        //     }*/
        // }
    }
    
    // 监听属性变化,触发重绘
    onDetectionDataChanged: {
        canvas.requestPaint()
        // dataChanged(detectionData.length)
    }
    
    // 监听视频尺寸变化
    Connections {
        target: videoOutput
        function onWidthChanged() { 
            root.updateVideoDisplayRect()
            canvas.requestPaint()
        }
        function onHeightChanged() { 
            root.updateVideoDisplayRect()
            canvas.requestPaint()
        }
        function onSourceRectChanged() {
            root.updateVideoDisplayRect()
            canvas.requestPaint()
        }
    }
    Connections {
        target: videoSink
        function onVideoFrameChanged(frame) {
            root.frameReceived();
        }
    }
}
