import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects



Item {
    id: root
    // width: 800
    // height: 600
    signal toggleDetect


    ColumnLayout{
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            ColumnLayout {
                id: modelPathArea
                anchors.fill: parent
                anchors.margins: 20
                // spacing: 20
                // 公共属性
                property string selectedPath: ""           // 选择的文件路径
                property alias titleText: titleLabel.text  // 标题文本，默认为"Model Path"
                // property alias buttonText: browseButton.text // 按钮文本
                property string fileFilter: "PT files (*.pt)"
                property string initialFolder: "" // 初始目录

                // 信号
                signal pathChanged(string newPath) // 路径改变时发出信号
                signal fileSelected(string filePath) // 文件选择完成时发出信号
                Item{
                    id: modelPathTitle
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 2
                    RowLayout {
                        anchors.fill: parent
                        // Layout.fillWidth: true
                        // Layout.fillHeight: true
                        // Layout.preferredHeight: 1
                        Layout.alignment: Qt.AlignHCenter
                        // 标题
                        Label {
                            id: titleLabel
                            text: "Model Path"
                            font.bold: true
                            font.pixelSize: 16
                            color: "white"
                            //
                        }

                        // 占位空间，使按钮靠右
                        Item {
                            Layout.fillWidth: true
                        }

                        Item {

                            width: 40
                            height: 40

                            ToolButton {
                                id: fileButton
                                anchors.fill: parent

                                // 设置背景颜色
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: parent.pressed ? "#1c1c1e" :
                                           parent.hovered ? "#000000" : "transparent"
                                    radius: 6
                                    // border.color: "#27ae60"
                                    // border.width: 2
                                }
                                padding: 2
                                icon {
                                    source: "images/file.svg"
                                    height: parent.height; width: parent.width
                                    color: fileButton.hovered ? "white" : "gray"
                                }
                                onClicked: {
                                    fileDialog.open()
                                }
                            }
                        }

                    }
                }


                Item{

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1
                    //
                    Label{

                        id: modelPathLabel
                        x: 0
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.Wrap
                        anchors.verticalCenterOffset: 2
                        text: "home/dutrue/projects/py_projects/ultralytics-main/best.pt"
                        font.pixelSize: 12
                        color: "white"

                    }
                }
                FileDialog {
                    id: fileDialog
                    title: "选择模型文件"
                    // currentFolder: root.initialFolder ? root.initialFolder : shortcuts.home
                    fileMode: FileDialog.OpenFile
                    nameFilters: [modelPathArea.fileFilter]

                    onAccepted: {
                        // 获取文件路径（去除 file:// 前缀）
                        var filePath = fileDialog.currentFile.toString()
                        if (filePath.startsWith("file:///")) {
                            filePath = filePath.substring(8)  // Linux/Windows
                        } else if (filePath.startsWith("file://")) {
                            filePath = filePath.substring(7)  // macOS
                        }
                        console.log(filePath)
                        modelPathLabel.text = filePath
                    }

                    onRejected: {
                        console.log("用户取消了文件选择")
                    }
                }

                // 初始化
                Component.onCompleted: {
                    console.log("ModelPathSelector 组件初始化完成")
                }
            }
        }

        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 1.5

            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 20
                // spacing: 0
                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    RowLayout{
                        anchors.fill: parent
                        Label{
                            text: "Confidence"
                            font.bold: true
                            font.pixelSize: 16
                            color: "white"
                        }
                        Item{
                            Layout.fillWidth: true
                        }
                        Label{
                            id: confidenceValue
                            text: "0.50"
                            font.bold: true
                            font.pixelSize: 16
                            color: "white"
                        }
                    }
                }

                Item{
                    Layout.fillHeight: true
                }

                Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1


                    Slider {
                        anchors.centerIn: parent
                        id: control
                        value: 0.5
                        width: parent.width
                        // 滑轨背景（未滑过的部分）
                        background: Rectangle {
                            x: control.leftPadding
                            y: control.topPadding + control.availableHeight / 2 - height / 2
                            // implicitWidth: 200
                            // implicitHeight: 4
                            width: control.availableWidth
                            height: 2
                            radius: 2
                            color: "gray"  // 灰色背景

                            // 已滑过的部分（白色）
                            Rectangle {
                                width: control.visualPosition * parent.width
                                height: parent.height
                                color: "#ffffff"  // 白色
                                radius: 2
                            }

                        }

                        // 滑块
                        handle: Rectangle {
                            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                            y: control.topPadding + control.availableHeight / 2 - height / 2
                            implicitWidth: 16
                            implicitHeight: 16
                            radius: width / 2
                            color: "#3A3A3C"
                            border.width: 2
                            border.color: "#404042"

                            // 外阴影
                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: 3
                                verticalOffset: 3
                                radius: 10
                                samples: 21
                                color: "#111112"
                                spread: 0.2
                            }

                            // 内阴影 - 使用圆形遮盖
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.width: 1
                                border.color: "#202022"
                            }
                        }
                        onMoved: {
                            confidenceValue.text = control.value.toFixed(2).toString()
                        }
                    }

                }
            }
            Rectangle{
                x: 20
                width: parent.width - 40
                height: 2
                color: "#252527"
                anchors.top: parent.top
                // anchors.leftMargin: 20
            }
        }

        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 1.5
            ColumnLayout{
                anchors.fill: parent
                anchors.margins: 20

                // Text {
                //     Layout.fillWidth: true
                //     text: qsTr("detect stride")
                //     font.bold: true
                //     color: "white"
                // }
                Label{
                    text: "Detect Stride"
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                }
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true


                    RowLayout{
                        id: confidenceLayout
                        anchors.fill: parent
                        spacing: 20

                        Item{
                            width: 40
                            height: 40
                            Rectangle {
                                width: 36
                                height: 36
                                id: detectStrideMin
                                anchors.centerIn: parent
                                radius: width / 2
                                color: "#3A3A3C"
                                border.width: 2
                                border.color: "#404042"

                                // 外阴影
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    horizontalOffset: 3
                                    verticalOffset: 3
                                    radius: 10
                                    samples: 21
                                    color: "#111112"
                                    spread: 0.2
                                }

                                // 内阴影 - 使用圆形遮盖
                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.width: 1
                                    border.color: "#202022"
                                }
                            }

                            Label{
                                anchors.centerIn: detectStrideMin
                                text: "0"
                                // font.bold: true
                                font.pixelSize: 13
                                color: "white"
                            }
                        }
                        Slider {
                            // anchors.centerIn: parent
                            id: detectStrideControl
                            value: 0.5
                            Layout.fillWidth: true
                            from: 0
                            to: 1.9
                            // 滑轨背景（未滑过的部分）
                            function getAroundValue(num) {
                                // console.log(num, 11111111111111)
                                if (num < 0.95) {
                                    return num;
                                } else if (num < 1.05) {
                                    return 1;
                                } else { // num >= 1.5
                                    return Math.round(num * 10) - 9;
                                }
                            }
                            background: Rectangle {
                                x: detectStrideControl.leftPadding
                                y: detectStrideControl.topPadding + detectStrideControl.availableHeight / 2 - height / 2
                                // implicitWidth: 200
                                // implicitHeight: 4
                                width: detectStrideControl.availableWidth
                                height: 2
                                radius: 2
                                color: "gray"  // 灰色背景

                                // Rectangle {
                                //     x: parent.width
                                //     width: 4
                                //     height: parent.height
                                //     // width: detectStrideControl.visualPosition * parent.width
                                //     // height: parent.height
                                //     color: "#ffffff"  // 白色
                                //     // radius: 2
                                // }
                                // 已滑过的部分（白色）
                                Rectangle {
                                    width: detectStrideControl.visualPosition * parent.width
                                    height: parent.height
                                    color: "#ffffff"  // 白色
                                    radius: 2
                                }
                                Rectangle {
                                    width: 2
                                    height: parent.height + 8
                                    color: "#ffffff"
                                    // x: parent.width / 2 - width / 2
                                    x: 0
                                    y: -4
                                    z: 1
                                }
                                Rectangle {
                                    width: 2
                                    height: parent.height + 8
                                    color: "#ffffff"
                                    x: parent.width / 2 - width / 2
                                    y: -4
                                    z: 1
                                }
                                Rectangle {
                                    width: 2
                                    height: parent.height + 8
                                    color: "#ffffff"
                                    x: parent.width - 2
                                    y: -4
                                    z: 1
                                }
                            }

                            // 滑块
                            handle: Rectangle {
                                x: detectStrideControl.leftPadding + detectStrideControl.visualPosition * (detectStrideControl.availableWidth - width)
                                y: detectStrideControl.topPadding + detectStrideControl.availableHeight / 2 - height / 2
                                // implicitWidth: 16  // 直径8，半径4
                                // implicitHeight: 16
                                // radius: 8
                                // color: detectStrideControl.pressed ? "#f0f0f0" : "#ffffff"
                                // border.color: "#b0b0b0"
                                // border.width: 1


                                implicitWidth: 16
                                implicitHeight: 16
                                radius: width / 2
                                color: "#3A3A3C"
                                border.width: 2
                                border.color: "#404042"

                                // 外阴影
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    horizontalOffset: 3
                                    verticalOffset: 3
                                    radius: 10
                                    samples: 21
                                    color: "#111112"
                                    spread: 0.2
                                }

                                // 内阴影 - 使用圆形遮盖
                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.width: 1
                                    border.color: "#202022"
                                }
                            }
                            onMoved: {
                                // confidenceValue.text = detectStrideControl.value.toFixed(2).toString()
                                // console.log(detectStrideControl.value)
                                // if (detectStrideControl.value >1){
                                //     var value = Math.round((detectStrideControl.value.toFixed(1)) * 10) - 9
                                //     detectStrideValue.text = value.toString()
                                // }else{
                                //     // console.log(detectStrideControl.value.toFixed(21)
                                //     detectStrideValue.text = detectStrideControl.value.toFixed(1).toString()
                                // }
                                var value = detectStrideControl.value.toFixed(1)
                                console.log(value)
                                detectStrideValue.text = getAroundValue(value)
                                // switch (value){}

                            }
                        }

                        Item{
                            width: 40
                            height: 40
                            Rectangle {
                                width: 36
                                height: 36
                                id: detectStrideMax
                                anchors.centerIn: parent
                                radius: width / 2
                                color: "#3A3A3C"
                                border.width: 2
                                border.color: "#404042"

                                // 外阴影
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    horizontalOffset: 3
                                    verticalOffset: 3
                                    radius: 10
                                    samples: 21
                                    color: "#111112"
                                    spread: 0.2
                                }

                                // 内阴影 - 使用圆形遮盖
                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.width: 1
                                    border.color: "#202022"
                                }
                            }

                            Label{
                                id: detectStrideValue
                                anchors.centerIn: detectStrideMax
                                text: "0.5"
                                // font.bold: true
                                font.pixelSize: 13
                                color: "white"
                            }
                        }
                    }
                }
            }
            Rectangle{
                x: 20
                width: parent.width - 40
                height: 2
                color: "#252527"
                anchors.top: parent.top
                // anchors.leftMargin: 20
            }
        }

        Item{
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            RowLayout{
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                // Layout.alignment: Qt.AlignHCenter

                // Text {

                //     text: qsTr(" start ,stop")
                //     color: "white"
                // }

                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Rectangle {
                        width: 36
                        height: 36
                        id: test
                        anchors.centerIn: parent
                        radius: width / 2
                        color: "#3A3A3C"
                        border.width: 2
                        border.color: "#404042"

                        // 外阴影
                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 3
                            verticalOffset: 3
                            radius: 10
                            samples: 21
                            color: "#111112"
                            spread: 0.2
                        }

                        // 内阴影 - 使用圆形遮盖
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.width: 1
                            border.color: "#202022"
                        }
                    
                    }

                    Label{
                        anchors.centerIn: test
                        text: "开始"
                        // font.bold: true
                        font.pixelSize: 13
                        color: "white"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            root.toggleDetect()
                        }
                    }
                }
                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Rectangle {
                        width: 36
                        height: 36
                        id: test2
                        anchors.centerIn: parent
                        radius: width / 2
                        color: "#3A3A3C"
                        border.width: 2
                        border.color: "#404042"

                        // 外阴影
                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 3
                            verticalOffset: 3
                            radius: 10
                            samples: 21
                            color: "#111112"
                            spread: 0.2
                        }

                        // 内阴影 - 使用圆形遮盖
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.width: 1
                            border.color: "#202022"
                        }
                    }

                    Label{
                        anchors.centerIn: test2
                        text: "0.8"
                        // font.bold: true
                        font.pixelSize: 13
                        color: "white"
                    }
                    
                }

                Item{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Rectangle {
                        width: 36
                        height: 36
                        id: test3
                        anchors.centerIn: parent
                        radius: width / 2
                        color: "#3A3A3C"
                        border.width: 2
                        border.color: "#404042"

                        // 外阴影
                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 3
                            verticalOffset: 3
                            radius: 10
                            samples: 21
                            color: "#111112"
                            spread: 0.2
                        }

                        // 内阴影 - 使用圆形遮盖
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.width: 1
                            border.color: "#202022"
                        }
                    }

                    Label{
                        anchors.centerIn: test3
                        text: "0.8"
                        // font.bold: true
                        font.pixelSize: 13
                        color: "white"
                    }
                }

            }
            Rectangle{
                x: 20
                width: parent.width - 40
                height: 2
                color: "#252527"
                anchors.top: parent.top
                // anchors.leftMargin: 20
            }
        }




    }

}
