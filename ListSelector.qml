// 此文件时做一个列表选择器，可以滑动选择，动画停止后500ms触发changeRequested，使用时，外部需要定义触发什么动作，这个信号带两个参数，一个是model的item，一个是当前的index
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: listSelector
    // width: 300
    // height: 400
    color: "transparent"

    // 公共属性
    property string propertyName: "name"
    property var model: ListModel {  // 默认模型,必须有name属性
        ListElement { name: "property" }
        ListElement { name: "property" }
        ListElement { name: "property" }
        ListElement { name: "property" }
    }
    property int visibleItems: 4  // 可视项目数量
    property int currentIndex: 0
    property int listModelHeight: listSelector - 20

    // 信号
    signal changeRequested(var item, int index)
    signal changeCompleted(bool success)
    signal changeStarted()

    // 切换定时器
    Timer {
        id: switchTimer
        interval: 500  // 动画完成后500ms再真正切换
        repeat: false
        onTriggered: {
            applyChangeNow()
        }
    }

    // 应用分辨率切换（延迟模式）
    function applyChange() {
        if (currentIndex >= 0) {
            changeStarted()
            switchTimer.stop()
            switchTimer.start()
        }
    }

    // 立即应用分辨率切换
    function applyChangeNow() {
        if (model && model.get && currentIndex >= 0) {
            var currentItem = model.get(currentIndex)
            if (currentItem) {
                // console.log("Applying changes:", currentItem.name)
                // changeRequested({
                //     name: currentItem.name,
                //     width: currentItem.widthValue || currentItem.width,
                //     height: currentItem.heightValue || currentItem.height,
                //     aspectRatio: currentItem.aspectRatio
                // }, currentIndex)
                changeRequested(currentItem, currentIndex)  // item自己处理
            }
        }
    }

    // 刷新模型数据
    function refreshModel(newData) {
        if (model && model.clear && model.append) {
            model.clear()
            if (Array.isArray(newData)) {
                for (var i = 0; i < newData.length; i++) {
                    model.append(newData[i])
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        // spacing: 8

        // 属性名称
        Item {
            id: nameRect
            width: parent.width
            height: 20
            // color: "transparent"

            Text {
                text: propertyName
                font.pixelSize: 16
                font.bold: true
                color: '#7e7979'
                anchors.centerIn: parent
            }
        }

        // 滚动区域
        Item {
            id: scrollRect
            width: parent.width
            height: parent.height - nameRect.height
            // color: "transparent"
            // radius: 8
            // border.color: "#DDDDDD"
            // border.width: 2

            ListView {
                id: listView
                anchors.fill: parent
                // anchors.margins: 10
                function setFocus() {
                    listSelector.setFocus()
                }
                model: listSelector.model
                delegate: ListSelectorDelegate {
                    onScrollRectItemClicked: {
                        applyChange()
                    }
                }

                // 布局设置
                snapMode: ListView.SnapToItem
                preferredHighlightBegin: scrollRect.height / 2 - (scrollRect.height / visibleItems) / 2
                preferredHighlightEnd: scrollRect.height / 2 + (scrollRect.height / visibleItems) / 2
                highlightRangeMode: ListView.StrictlyEnforceRange
                highlightMoveDuration: 300

                // 交互
                clip: true
                interactive: true

                // 滚动结束时的处理
                onMovementEnded: {
                    listSelector.applyChange()
                    
                }
                // 当前索引变化
                onCurrentIndexChanged: {
                    console.log("list的index改变了: " + listView.currentIndex)
                    listSelector.currentIndex = listView.currentIndex
                }
            }
            
            

            // 上下渐变遮罩
            // Rectangle {
            //     anchors.top: parent.top
            //     width: parent.width
            //     height: 20
            //     gradient: Gradient {
            //         GradientStop { position: 0.0; color: "#1C1C1E" }
            //         GradientStop { position: 1.0; color: "transparent" }
            //     }
            // }

            // Rectangle {
            //     anchors.bottom: parent.bottom
            //     width: parent.width
            //     height: 20
            //     gradient: Gradient {
            //         GradientStop { position: 0.0; color: "transparent" }
            //         GradientStop { position: 1.0; color: "#1C1C1E" }
            //     }
            // }
        }

    }
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.01
        color: "#252527"
    }
    // 键盘导航
    Keys.onUpPressed: {
        console.log(currentIndex, 111111111)
        if (currentIndex > 0) {
            listView.currentIndex--
            listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            applyChange()
        }
    }

    Keys.onDownPressed: {
        console.log(currentIndex, listView.count - 1, 222222222)
        if (currentIndex < listView.count - 1) {
            listView.currentIndex++
            listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            applyChange()
        }
    }

    // 点击区域内的时候设置焦点

    function setFocus() {
        forceActiveFocus()
    }
    // 组件加载完成后设置焦点
    // Component.onCompleted: {
        
    // }
}

