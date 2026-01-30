// 模式切换栏 - 类似DJI的 Video/Photo 标签式按钮 + 功能按钮
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: root
    color: "transparent"
    
    // 属性
    property CaptureSession captureSession
    property bool previewAvailable: false
    property string currentMode: "photo"  // "photo" 或 "video"
    property bool isDetectionEnabled: false  // 检测是否启用

    property alias listSelector: resolutionSelector
    
    // 相机格式相关属性
    property var cameraFormats: []  // 从 DeclarativeCamera 接收的格式列表
    property var currentCameraFormat: null
    

    property alias targetNum: targetNum
    property alias currentPosition: currentPosition
    // 监听 cameraFormats 属性变化
    // onCameraFormatsChanged: {
    //     console.log("触发 cameraFormats changed信号:");
    //     updateModel();
    // }
    
    // 信号
    signal photoModeSelected()
    signal videoModeSelected()
    signal previewSelected()
    signal captureRequested()
    signal recordRequested()
    signal stopRequested()
    signal toggleDetection()  // 切换检测状态
    signal togglePreviewResolution(var format)  // 切换预览状态分辨率
    
    // 帧率计算相关属性
    property real fps: 0.0
    property int frameCount: 0
    property int frameCountRound: 0
    property real lastFrameTime: 0
    property var frameTimes: []
    property int maxFrameTimes: 30  // 用于计算平均FPS的帧数
    
    // 帧率计算函数
    function updateFrameRate() {
        var currentTime = Date.now() / 1000.0; // 转换为秒
        
        if (root.lastFrameTime === 0) {
            root.lastFrameTime = currentTime;
            return;
        }
        
        // 更新总帧数
        root.frameCount++;
        
        // 添加当前时间到时间数组
        root.frameTimes.push(currentTime);
        
        // 如果超过最大数量，移除最早的记录
        if (root.frameTimes.length > root.maxFrameTimes) {
            root.frameTimes.shift();
        }
        
        // 计算平均帧率（基于最近的帧）
        if (root.frameTimes.length >= 2) {
            var timeSpan = root.frameTimes[root.frameTimes.length - 1] - root.frameTimes[0];
            if (timeSpan > 0) {
                root.fps = ((root.frameTimes.length - 1) / timeSpan).toFixed(1);
            }
        }
        
        root.lastFrameTime = currentTime;
    }
    
    // 重置帧计数（可选）
    function resetFrameCount() {
        root.frameCount = 0;
        root.fps = 0.0;
        root.frameTimes = [];
        root.lastFrameTime = 0;
        
        if (fpsValue) {
            fpsValue.text = "0.0";
        }
        if (frameCountValue) {
            frameCountValue.text = "0";
        }
    }

    Timer{

        id: fpsTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            fpsValue.text = root.fps;
            frameCountValue.text = root.frameCountRound * 1000000 + root.frameCount + "";
            if (root.frameCount > 1000000){
                root.frameCountRound++;
                root.frameCount = 0;
            }
        }
    }

    // 分辨率属性
    property var previewResolutionOptions: ["1920x1080", "1280x720", "640x480"]
    property string previewResolution: "1920x1080"


    function updateModel() {
        console.log("Updating model with cameraFormats:", cameraFormats);
        
        // 清空现有的模型
        formatComboBox.model.clear();
        
        // 检查 cameraFormats 是否存在且不为空
        if (cameraFormats && cameraFormats.length > 0) {
            formatComboBox.model.append({
                                            text: "默认格式",
                                            // formatData: format
                                        })
            for (var i = 1; i < cameraFormats.length; i++) {
                var format = cameraFormats[i];
                if (format) {
                    // 获取分辨率信息
                    var resolution = format.resolution;
                    var maxFrameRate = format.maxFrameRate;
                    var pixelFormat = format.pixelFormat;
                    
                    // 添加到模型中
                    formatComboBox.model.append({
                                                    text: resolution.width + "x" + resolution.height + " (" + (maxFrameRate || "?") + "fps, " + (pixelFormat || "?") + ")",
                                                    // formatData: format
                                                });
                }
            }
            
            // 设置默认选中项
            if (formatComboBox.model.count > 0) {
                formatComboBox.currentIndex = 0;
            }
        } else {
            console.log("No camera formats available");
        }
    }

    // 按钮样式配置
    readonly property color activeColor: "#FFFFFF"
    readonly property color inactiveColor: "#808080"
    readonly property color activeBgColor: "#1C1C1E"
    readonly property color inactiveBgColor: "transparent"
    readonly property int buttonHeight: 26
    readonly property int modeButtonWidth: 100
    readonly property int funcButtonWidth: 80
    readonly property int fontSize: 14
    
    // 主布局 - 左右分布
    RowLayout {
        anchors.fill: parent
        // anchors.margins: 15
        spacing: 10
        anchors.margins: 20
        Item {
            //
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            // height: 200
            // color:"transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                // 左侧：模式切换按钮（Video/Photo）
                Rectangle{
                    id: modeLayout
                    // width: root.modeButtonWidth * 2 + 8
                    // height: root.buttonHeight + 8
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    radius: 8 * 1.414
                    color: "black"
                    // anchors.margins: 5
                    Item {
                        id: layout1
                        anchors.fill: parent
                        anchors.margins: 4

                        Row {
                            anchors.fill: parent

                            spacing: 0

                            // Video 按钮
                            Rectangle {
                                id: videoButton
                                width: layout1.width / 2
                                height: layout1.height
                                color: root.currentMode === "video" ? root.activeBgColor : root.inactiveBgColor
                                radius: 8

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    width: parent.radius
                                    height: parent.height
                                    color: parent.color
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "📹 Video"
                                    font.pixelSize: root.fontSize
                                    font.bold: root.currentMode === "video"
                                    color: root.currentMode === "video" ? root.activeColor : root.inactiveColor
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width * 0.6
                                    height: 3
                                    color: "#007AFF"
                                    visible: root.currentMode === "video"
                                    radius: 1.5
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.currentMode = "video"
                                        root.videoModeSelected()
                                    }
                                }
                            }

                            // Photo 按钮
                            Rectangle {
                                id: photoButton
                                width: layout1.width / 2
                                height: layout1.height
                                color: root.currentMode === "photo" ? root.activeBgColor : root.inactiveBgColor
                                radius: 8

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    width: parent.radius
                                    height: parent.height
                                    color: parent.color
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "📷 Photo"
                                    font.pixelSize: root.fontSize
                                    font.bold: root.currentMode === "photo"
                                    color: root.currentMode === "photo" ? root.activeColor : root.inactiveColor
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width * 0.6
                                    height: 3
                                    color: "#007AFF"
                                    visible: root.currentMode === "photo"
                                    radius: 1.5
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.currentMode = "photo"
                                        root.photoModeSelected()
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    radius: 8 * 1.414
                    color: "black"
                    Item {
                        id: layout2
                        anchors.fill: parent
                        anchors.margins: 4
                        GridLayout {
                            // Layout.alignment: Qt.AlignVCenter
                            // Layout.fillWidth: true
                            // spacing: 10
                            columns:2
                            rows: 2
                            // Photo 模式按钮
                            Item {
                                // width: root.funcButtonWidth
                                width: layout2.width / 2 - 2
                                height: layout2.height / 4 - 2
                                visible: root.currentMode === "photo"

                                // 拍照按钮
                                Button {
                                    anchors.fill: parent
                                    text: "📸 Capture"
                                    font.pixelSize: root.fontSize
                                    // visible: root.captureSession && root.captureSession.imageCapture.readyForCapture
                                    onClicked: root.captureRequested()

                                    background: Rectangle {
                                        color: parent.pressed ? "#3A3A3C" : root.activeBgColor
                                        radius: 6
                                        border.color: "#007AFF"
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font: parent.font
                                        color: root.activeColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            // Video 模式按钮
                            Item {
                                // width: root.funcButtonWidth
                                width: layout2.width / 2 - 2
                                height: layout2.height / 4 - 2
                                visible: root.currentMode === "video"

                                // 录制按钮
                                Button {
                                    anchors.fill: parent
                                    text: "⏺ Record"
                                    font.pixelSize: root.fontSize
                                    // visible: root.captureSession && root.captureSession.recorder.recorderState !== MediaRecorder.RecordingState
                                    onClicked: root.recordRequested()

                                    background: Rectangle {
                                        color: parent.pressed ? "#3A3A3C" : "#DC3545"
                                        radius: 6
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font: parent.font
                                        color: root.activeColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Item {
                                // width: root.funcButtonWidth
                                width: layout2.width / 2 - 2
                                height: layout2.height / 4 - 2
                                visible: root.currentMode === "video"

                                // 停止录制按钮
                                Button {
                                    anchors.fill: parent
                                    text: "⏹ Stop"
                                    font.pixelSize: root.fontSize
                                    // visible: root.captureSession && root.captureSession.recorder.recorderState === MediaRecorder.RecordingState
                                    onClicked: root.stopRequested()

                                    background: Rectangle {
                                        color: parent.pressed ? "#3A3A3C" : root.activeBgColor
                                        radius: 6
                                        border.color: "#DC3545"
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font: parent.font
                                        color: root.activeColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }

                            Item {
                                // width: root.funcButtonWidth
                                width: layout2.width / 2 - 2
                                height: layout2.height / 4 - 2

                                // visible: root.currentMode === "video"
                                visible: root.previewAvailable

                                Button {
                                    anchors.fill: parent
                                    text: "👁 View"
                                    font.pixelSize: root.fontSize
                                    //
                                    onClicked: root.previewSelected()

                                    background: Rectangle {
                                        color: parent.pressed ? "#3A3A3C" : root.activeBgColor
                                        radius: 6
                                        border.color: "#DC3545"
                                        border.width: 1
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        font: parent.font
                                        color: root.activeColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 3
            // color:"transparent"
            ColumnLayout{
                anchors.fill: parent
                spacing: 20
                Rectangle{
                    // width: root.modeButtonWidth * 2 + 8
                    // height: root.buttonHeight + 8
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    radius: 8 * 1.414
                    color: "black"
                    // anchors.margins: 5
                    Item{
                        id: test
                        anchors.fill: parent
                        anchors.margins: 2

                        ComboBox {
                            id: cameraComboBox
                            x: 2
                            y: 2

                            width: parent.width - 4
                            height: parent.height - 4

                            property var mediaDevices: MediaDevices {
                                id: mediaDevices
                            }

                            model: mediaDevices.videoInputs
                            textRole: "description"

                            currentIndex: 0

                            onActivated: {
                                if (root.captureSession && currentIndex >= 0) {
                                    root.captureSession.camera.cameraDevice = mediaDevices.videoInputs[currentIndex]
                                }
                            }

                            background: Rectangle {
                                color: cameraComboBox.pressed ? "#3A3A3C" : root.activeBgColor
                                radius: 8
                                border.color: "#17A2B8"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: "📹 " + (cameraComboBox.currentText || "Camera")
                                font.pixelSize: root.fontSize
                                color: root.activeColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                            popup: Popup {
                                y: cameraComboBox.height
                                width: cameraComboBox.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: cameraComboBox.popup.visible ? cameraComboBox.delegateModel : null
                                    currentIndex: cameraComboBox.highlightedIndex

                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }

                                background: Rectangle {
                                    color: "#2C2C2E"
                                    border.color: "#17A2B8"
                                    radius: 4
                                }
                            }

                            delegate: ItemDelegate {
                                width: cameraComboBox.popup.width
                                height: root.buttonHeight

                                // 直接设置 ItemDelegate 的 text
                                text: modelData ? modelData.description : ""

                                highlighted: cameraComboBox.highlightedIndex === index

                                background: Rectangle {
                                    color: highlighted ? "#3A3A3C" : "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: root.activeColor
                                    font.pixelSize: root.fontSize
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    leftPadding: 10
                                }
                            }
                        }

                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    RowLayout{

                        anchors.fill: parent
                        anchors.topMargin: 20
                        anchors.bottomMargin: 20
                        spacing: 10


                        Item {
                            id: layout3
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            anchors.margins: 4
                            ColumnLayout{
                                anchors.fill: parent
                                spacing: 4
                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    // id: nameRect
                                    // width: parent.width
                                    // height: 20
                                    // color: "transparent"
                                    ColumnLayout{
                                        anchors.fill: parent

                                        Label {
                                            
                                            text: "FrameCount"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: '#7e7979'
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Label{
                                            id: frameCountValue
                                            text: "16"
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: 'white'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    // id: nameRect
                                    // width: parent.width
                                    // height: 20
                                    // color: "transparent"
                                    ColumnLayout{
                                        anchors.fill: parent

                                        Label {
                                            text: "FPS"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: '#7e7979'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Label{
                                            id: fpsValue
                                            text: "16"
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: 'white'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    // id: nameRect
                                    // width: parent.width
                                    // height: 20
                                    // color: "transparent"
                                    ColumnLayout{
                                        anchors.fill: parent

                                        Label {
                                            text: "FPS"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: '#7e7979'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Label{
                                            text: "16"
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: 'white'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                            }
                        }

                        Item{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            anchors.margins: 4
                            ListSelector{
                                id: wbListSelector
                                anchors.fill: parent
                                propertyName: "WhiteBalance"
                                Component.onCompleted: {
                                    var newData = [
                                                {name: "⚙️ Auto", value: Camera.WhiteBalanceAuto},
                                                {name: "☀️ Sunny", value: Camera.WhiteBalanceSunlight},
                                                {name: "⛅️ Cloudy", value: Camera.WhiteBalanceCloudy},
                                                {name: "💡 Tungsten", value: Camera.WhiteBalanceTungsten},
                                                {name: "💡 Fluorescent", value: Camera.WhiteBalanceFluorescent}
                                            ]
                                    wbListSelector.refreshModel(newData)
                                }
                                onChangeRequested: function(item, index) {
                                    // console.log("ComboBox: " + item.name)
                                    // console.log("ComboBox: " + item.value)
                                    if (root.captureSession) {
                                        // console.log("ComboBox: " + item.name)
                                        // console.log(root.captureSession.camera.whiteBalanceMode)
                                        root.captureSession.camera.whiteBalanceMode = item.value
                                    }
                                }
                            }
                        }

                        Item{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            anchors.margins: 4
                            ListSelector {
                                id: resolutionSelector
                                anchors.fill: parent
                                propertyName: "resolution"
                                onChangeRequested: function(item, index){
                                    captureSession.camera.cameraFormat = root.cameraFormats[index]
                                }
                                Component.onCompleted: {
                                    var newData = []
                                    for (var i = 0; i < root.cameraFormats.length; i++) {
                                        var resolution = root.cameraFormats[i].resolution.width + ":" + root.cameraFormats[i].resolution.height
                                        newData.push({
                                                         name: resolution,
                                                         value: i
                                                     })
                                    }
                                    console.log("refreshing model", root.cameraFormats)
                                    resolutionSelector.refreshModel(newData)
                                }
                            }
                        }
                        Item {
                            id: layout6
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            anchors.margins: 4
                            ColumnLayout{
                                anchors.fill: parent
                                spacing: 4
                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    // id: nameRect
                                    // width: parent.width
                                    // height: 20
                                    // color: "transparent"
                                    ColumnLayout{
                                        anchors.fill: parent

                                        Label {

                                            text: "MousePosition"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: '#7e7979'
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Label{
                                            id: currentPosition
                                            text: "16"
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: 'white'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    // id: nameRect
                                    // width: parent.width
                                    // height: 20
                                    // color: "transparent"
                                    ColumnLayout{
                                        anchors.fill: parent

                                        Label {

                                            text: "Targets"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: '#7e7979'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Label{
                                            id: targetNum
                                            text: "16"
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: 'white'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    // id: nameRect
                                    // width: parent.width
                                    // height: 20
                                    // color: "transparent"
                                    ColumnLayout{
                                        anchors.fill: parent

                                        Label {
                                            text: "test"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: '#7e7979'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Label{
                                            text: "16"
                                            font.pixelSize: 18
                                            font.bold: true
                                            color: 'white'

                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Item{
        //     Layout.fillHeight: true
        //     Layout.fillWidth: true
        //     Layout.preferredWidth: 1
        //     // color:"transparent"

        //     ColumnLayout{
        //         anchors.fill: parent
        //         spacing: 20
        //         Rectangle{
        //             // width: root.modeButtonWidth * 2 + 8
        //             // height: root.buttonHeight + 8
        //             Layout.fillHeight: true
        //             Layout.fillWidth: true
        //             Layout.preferredHeight: 1
        //             radius: 8 * 1.414
        //             color: "black"
        //             // anchors.margins: 5
        //             Item{

        //                 anchors.fill: parent
        //                 anchors.margins: 2

        //                 Rectangle{
        //                     width: parent.width - 4
        //                     height: parent.height -4
        //                     x:2
        //                     y:2
        //                     radius: 8
        //                 }
        //             }
        //         }
        //         Item {
        //             Layout.fillHeight: true
        //             Layout.fillWidth: true
        //             Layout.preferredHeight: 4

        //             RowLayout{

        //                 anchors.fill: parent
        //                 anchors.topMargin: 20
        //                 anchors.bottomMargin: 20
        //                 // spacing: 10


        //                 Item {

        //                     anchors.fill: parent
        //                     anchors.margins: 4
        //                     ColumnLayout{
        //                         anchors.fill: parent
        //                         spacing: 4
        //                         Item {
        //                             Layout.fillHeight: true
        //                             Layout.fillWidth: true

        //                             // id: nameRect
        //                             // width: parent.width
        //                             // height: 20
        //                             // color: "transparent"
        //                             ColumnLayout{
        //                                 anchors.fill: parent

        //                                 Label {
        //                                     text: "FrameCount"
        //                                     font.pixelSize: 14
        //                                     font.bold: true
        //                                     color: '#7e7979'

        //                                     Layout.alignment: Qt.AlignHCenter
        //                                 }
        //                                 Label{
        //                                     text: "16"
        //                                     font.pixelSize: 18
        //                                     font.bold: true
        //                                     color: 'white'

        //                                     Layout.alignment: Qt.AlignHCenter
        //                                 }
        //                             }
        //                         }
        //                         Item {
        //                             Layout.fillHeight: true
        //                             Layout.fillWidth: true
        //                             // id: nameRect
        //                             // width: parent.width
        //                             // height: 20
        //                             // color: "transparent"
        //                             ColumnLayout{
        //                                 anchors.fill: parent

        //                                 Label {
        //                                     text: "FPS"
        //                                     font.pixelSize: 14
        //                                     font.bold: true
        //                                     color: '#7e7979'

        //                                     Layout.alignment: Qt.AlignHCenter
        //                                 }
        //                                 Label{
        //                                     text: "16"
        //                                     font.pixelSize: 18
        //                                     font.bold: true
        //                                     color: 'white'

        //                                     Layout.alignment: Qt.AlignHCenter
        //                                 }
        //                             }
        //                         }
        //                         Item {
        //                             Layout.fillHeight: true
        //                             Layout.fillWidth: true
        //                             // id: nameRect
        //                             // width: parent.width
        //                             // height: 20
        //                             // color: "transparent"
        //                             ColumnLayout{
        //                                 anchors.fill: parent

        //                                 Label {
        //                                     text: "FPS"
        //                                     font.pixelSize: 14
        //                                     font.bold: true
        //                                     color: '#7e7979'

        //                                     Layout.alignment: Qt.AlignHCenter
        //                                 }
        //                                 Label{
        //                                     text: "16"
        //                                     font.pixelSize: 18
        //                                     font.bold: true
        //                                     color: 'white'

        //                                     Layout.alignment: Qt.AlignHCenter
        //                                 }
        //                             }
        //                         }
        //                     }
        //                 }
        //             }
        //         }
        //     }

        //     Button {
        //         width: root.funcButtonWidth + 20
        //         height: root.buttonHeight
        //         text: root.isDetectionEnabled ? "⏸️ 停止检测" : "▶️ 开始检测"
        //         font.pixelSize: root.fontSize
        //         onClicked: root.toggleDetection()

        //         background: Rectangle {
        //             color: parent.pressed ? "#3A3A3C" : (root.isDetectionEnabled ? "#DC3545" : "#28A745")
        //             radius: 6
        //             border.color: root.isDetectionEnabled ? "#FFC107" : "#17A2B8"
        //             border.width: 2
        //         }

        //         contentItem: Text {
        //             text: parent.text
        //             font: parent.font
        //             color: root.activeColor
        //             horizontalAlignment: Text.AlignHCenter
        //             verticalAlignment: Text.AlignVCenter
        //             // font.bold: true
        //         }
        //     }
        // }
    }

    // 平滑过渡动画
    Timer {
        id: fpsUpdateTimer
        interval: 1000  // 每秒更新一次
        running: true
        repeat: true
        onTriggered: {
            // 更新帧率显示
            root.updateFrameRate();
        }
    }
    
    Behavior on currentMode {
        PropertyAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}
