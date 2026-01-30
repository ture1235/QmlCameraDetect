import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

// Window {
//     id: mainWindow
//     width: 400
//     height: 600
//     visible: true
//     title: "正方形ToolButton布局 (修复版)"
//     color: "#f0f0f0"  // 设置窗口背景色，避免白色窗口问题

    // 主布局
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 2
        spacing: 2

        // 调试信息：显示主布局尺寸

        // ==== 区域1：1个正方形ToolButton ====
        Rectangle {
            id: area1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 1.5

            color: "transparent"
            Column {
                id: column1
                anchors.centerIn: parent

                property real button_size_1: Math.min(area1.width, area1.height) * 0.6
                spacing: button_size_1 * 0.2
                // spacing:10
                function handleButton1(){
                    console.log("按钮1被点击，执行特定操作1");
                }

                Item {
                    id: square1
                    width: Math.min(area1.width, area1.height) * 0.6
                    height: width

                    ToolButton {
                        id: btn1
                        anchors.fill: parent
                        padding: 0
                        // 设置背景颜色
                        background: Rectangle {
                            color: "transparent"
                        }
                        onClicked: {
                            column1.handleButton1()
                        }

                        icon.source: "images/title.svg"
                        icon.height: parent.height; icon.width: parent.width
                        icon.color:"white"

                    }
                }
            }
        }

        // ==== 区域2：4个正方形ToolButton ====
        Rectangle {
            id: area2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 4

            color: "transparent"
            Column {
                id: column2
                anchors.centerIn: parent

                property real button_size_2: Math.min(area2.width, area2.height / 4) * 0.5
                spacing: button_size_2 * 0.8
                // spacing:10
                function handleButton1(){
                    console.log("按钮1被点击，执行特定操作1");
                }

                function handleButton2() {
                    console.log("按钮2被点击，执行特定操作2");
                    // 这里可以执行按钮2的特定操作
                }

                function handleButton3() {
                    console.log("按钮3被点击，执行特定操作3");
                    // 这里可以执行按钮3的特定操作
                }

                function handleButton4() {
                    console.log("按钮4被点击，执行特定操作4");
                    // 这里可以执行按钮4的特定操作
                }

                // Repeater {
                //     model: 4

                Item {
                    id: square2_1
                    width: Math.min(area2.width, area2.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn2_1
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
                            source: "images/setting.svg"
                            height: parent.height; width: parent.width
                            color: btn2_1.hovered ? "white" : "gray"
                        }
                        onClicked: {
                            column2.handleButton1()
                        }
                    }
                }

                Item {
                    id: square2_2
                    width: Math.min(area2.width, area2.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn2_2
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
                            source: "images/setting.svg"
                            height: parent.height; width: parent.width
                            color: btn2_2.hovered ? "white" : "gray"
                        }
                        onClicked: {
                            column2.handleButton2()
                        }
                    }
                }

                Item {
                    id: square2_3
                    width: Math.min(area2.width, area2.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn2_3
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
                            source: "images/setting.svg"
                            height: parent.height; width: parent.width
                            color: btn2_3.hovered ? "white" : "gray"
                        }
                        onClicked: {
                            column2.handleButton3()
                        }
                    }
                }

                Item {
                    id: square2_4
                    width: Math.min(area2.width, area2.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn2_4
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
                            source: "images/setting.svg"
                            height: parent.height; width: parent.width
                            color: btn2_4.hovered ? "white" : "gray"
                        }
                        onClicked: {
                            column2.handleButton3()
                        }
                    }
                }

                // }
            }

            // 显示列尺寸
        }

        // ==== 区域3：3个正方形ToolButton + 1个占位 ====

        Rectangle {
            id: area3
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 4

            color: "transparent"
            // color: "#f8f8f8"
            // border.color: "#ccc"
            // border.width: 1
            // radius: 5

            // 调试信息
            Canvas {
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    // 绘制上边框
                    ctx.beginPath();
                    ctx.moveTo(10, 0);
                    ctx.lineTo(width - 10, 0);
                    ctx.lineWidth = 5;  // 边框宽度
                    ctx.strokeStyle = "gray";  // 边框颜色
                    ctx.stroke();

                    // 如果需要绘制其他边框
                    // ctx.beginPath();
                    // ctx.moveTo(0, height);
                    // ctx.lineTo(width, height);
                    // ctx.strokeStyle = "#2ecc71";  // 下边框颜色
                    // ctx.stroke();
                }

                // 当矩形大小改变时重绘
                onWidthChanged: requestPaint();
                onHeightChanged: requestPaint();
            }
            // 垂直布局容器
            Column {
                id: column3
                anchors.centerIn: parent
                property real button_size_3: Math.min(area3.width, area3.height / 4) * 0.5
                spacing: button_size_3 * 0.8

                // 3个正方形ToolButton
                function handleButton1() {
                    console.log("按钮1被点击，执行特定操作1");
                    // 这里可以执行按钮1的特定操作
                }

                function handleButton2() {
                    console.log("按钮2被点击，执行特定操作2");
                    // 这里可以执行按钮2的特定操作
                }

                function handleButton3() {
                    console.log("按钮3被点击，执行特定操作3");
                    // 这里可以执行按钮3的特定操作
                }
                function handleButton4() {
                    console.log("按钮4被点击，执行特定操作4");
                    // 这里可以执行按钮3的特定操作
                }

                Item {
                    id: square3_1
                    width: Math.min(area3.width, area3.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn3_1
                        anchors.fill: parent

                        // property string btnText: ["功能A", "功能B", "功能C"][index]

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
                            source: "images/setting.svg"
                            height: parent.height; width: parent.width
                            color: btn3_1.hovered ? "white" : "gray"
                        }

                        onClicked: {
                            column3.handleButton1()
                        }
                    }
                }

                Item {
                    id: square3_2
                    width: Math.min(area3.width, area3.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn3_2
                        anchors.fill: parent

                        // property string btnText: ["功能A", "功能B", "功能C"][index]

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
                            source: "images/setting.svg"
                            height: parent.height; width: parent.width
                            color: btn3_2.hovered ? "white" : "gray"
                        }

                        // contentItem: Text {
                        //     text: btn3.btnText
                        //     color: "white"
                        //     font.pixelSize: btn3.height * 0.25
                        //     font.bold: true
                        //     anchors.centerIn: parent
                        // }

                        onClicked: {
                            column3.handleButton2()
                        }
                    }
                }

                Item {
                    id: square3_3
                    width: Math.min(area3.width, area3.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn3_3
                        anchors.fill: parent
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
                            source: "images/setting.svg"
                            height: parent.height; width: parent.width
                            color: btn3_3.hovered ? "white" : "gray"
                        }

                        onClicked: {
                            column3.handleButton3()
                        }
                    }
                }

                Item {
                    id: square3_4
                    width: Math.min(area3.width, area3.height / 4) * 0.5
                    height: width

                    ToolButton {
                        id: btn3_4
                        anchors.fill: parent

                        // property string btnText: ["功能A", "功能B", "功能C"][index]

                        background: Rectangle {
                            anchors.fill: parent
                            // color: parent.pressed ? "#1c1c1e" :
                            //        parent.hovered ? "#000000" : "transparent"
                            // radius: 6
                            color: "transparent"
                            // border.color: "#27ae60"
                            // border.width: 2
                        }
                        // padding: 0

                        // onClicked: {
                        //     column3.handleButton4()
                        // }
                    }
                }

            }

        }


        // ==== 区域4：3个正方形ToolButton ====
        Rectangle {
            id: area4
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 2

            color: "transparent"
            // color: "#f8f8f8"
            // border.color: "#ccc"
            // border.width: 1
            Canvas {
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    // 绘制上边框
                    ctx.beginPath();
                    ctx.moveTo(10, 0);
                    ctx.lineTo(width - 10, 0);
                    ctx.lineWidth = 5;  // 边框宽度
                    ctx.strokeStyle = "gray";  // 边框颜色
                    ctx.stroke();
                }

                // 当矩形大小改变时重绘
                onWidthChanged: requestPaint();
                onHeightChanged: requestPaint();
            }
            // radius: 5

            // 调试信息

            // 3个正方形ToolButton
            Column {
                id: column4
                anchors.centerIn: parent
                property real button_size_4: Math.min(area4.width, area4.height / 3) * 0.5
                spacing: button_size_4 * 0.8

                // Repeater {
                //     model: 3
                Item {
                    id: square_none
                    width: Math.min(area4.width, area4.height / 3) * 0.5
                    height: width

                    ToolButton {
                        id: btn4_none
                        anchors.fill: parent

                        background: Rectangle{
                            color:"transparent"
                        }
                    }
                }

                Item {
                    id: square4
                    width: Math.min(area4.width, area4.height / 3) * 0.5
                    height: width

                    ToolButton {
                        id: btn4_1
                        anchors.fill: parent

                        background: Rectangle {
                            anchors.fill: parent
                            color: btn4_1.pressed ? "#1c1c1e" :
                                btn4_1.hovered ? "#000000" : "transparent"
                            radius: 6
                            // border.color: "#d68910"
                            // border.width: 2
                        }
                        padding:0
                        icon.source: "images/minsize.svg"
                        icon.height: btn4_1.height; icon.width: btn4_1.width
                        icon.color: btn4_1.hovered ? "white" : "gray"
                        onClicked: {
                            mainWindow.showMinimized()
                        }
                    }
                }
                // }

                Item {
                    id: square5
                    width: Math.min(area4.width, area4.height / 3) * 0.5
                    height: width

                    ToolButton {
                        id: btn4_2
                        anchors.fill: parent

                        background: Rectangle {
                            anchors.fill: parent
                            color: btn4_2.pressed ? "#1c1c1e" :
                                btn4_2.hovered ? "#000000" : "transparent"
                            radius: 6
                            // border.color: "#d68910"
                            // border.width: 2
                        }

                        padding: 0
                        icon.source: "images/change_size.svg"
                        icon.height: btn4_2.height; icon.width: btn4_2.width
                        icon.color: btn4_2.hovered ? "white" : "gray"

                        onClicked: {
                            if (mainWindow.visibility === Window.Maximized) {
                                mainWindow.showNormal()
                            } else {
                                mainWindow.showMaximized()
                            }
                        }
                    }
                }


                Item {
                    id: square6
                    width: Math.min(area4.width, area4.height / 3) * 0.5
                    height: width

                    ToolButton {
                        id: btn4_3
                        anchors.fill: parent
                        padding: 0
                        background: Rectangle {
                            anchors.fill: parent
                            color: parent.pressed ? "#1c1c1e" :
                                parent.hovered ? "#000000" : "transparent"
                            radius: 6
                            // border.color: "#d68910"
                            // border.width: 2
                        }

                        icon.source: "images/close_black.svg"
                        icon.height: btn4_3.height; icon.width: btn4_3.width
                        icon.color: btn4_3.hovered ? "white" : "gray"
                        onClicked: mainWindow.close()
                    }
                }
            }
        }

    }
    // 底部状态栏
// }
