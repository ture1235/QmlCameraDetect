//  listselector的delegate ，属性必须赋值name，用作展示listmodel里面的名字，其余随意
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: delegateItem
    width: ListView.view.width
    height: ListView.view.height / 4


    // property int index: model.index
    property string name: model.name
    // property int widthValue: model.widthValue || model.width
    // property int heightValue: model.heightValue || model.height
    // property string aspectRatio: model.aspectRatio

    property bool isCurrent: ListView.isCurrentItem
    property real scaleFactor: isCurrent ? 1.0 : 0.8
    property real opacityFactor: isCurrent ? 1.0 : 0.5

    // 点击事件的信号
    signal scrollRectItemClicked()

    // 转换缩放和透明度
    scale: scaleFactor
    opacity: opacityFactor

    // 动画效果
    Behavior on scale {
        NumberAnimation { duration: 300; easing.type: Easing.OutBack }
    }

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Item {
        anchors.fill: parent
        // anchors.margins: 5
        // radius: 8
        // color: isCurrent ? "#4A90E2" : "#F0F0F0"
        // border.color: isCurrent ? "#357ABD" : "#DDDDDD"
        // border.width: 2
        
        // color: "transparent"
        Text {
            anchors.centerIn: parent
            text: name
            font.pixelSize: isCurrent ? 16 : 12
            font.bold: isCurrent
            color: isCurrent ? "white" : '#7e7979'
            // anchors.horizontalCenter: parent.horizontalCenter
        }
        // Column {
        //     anchors.centerIn: parent
        //     // spacing: 5

            

        //     // Text {
        //     //     text: aspectRatio
        //     //     font.pixelSize: isCurrent ? 7 : 6
        //     //     color: isCurrent ? "#E6F2FF" : "#666666"
        //     //     anchors.horizontalCenter: parent.horizontalCenter
        //     //     visible: aspectRatio && aspectRatio !== ""
        //     // }
        // }
    }

    // 点击选择
    MouseArea {
        
        anchors.fill: parent
        onClicked: {
            delegateItem.ListView.view.setFocus()

            if (delegateItem.ListView.view && delegateItem.ListView.view.currentIndex !== undefined) {
                delegateItem.ListView.view.currentIndex = index
                console.log("dianjichufa")
                scrollRectItemClicked()
                // if (delegateItem.ListView.view.applyResolution) {

                //     delegateItem.ListView.view.applyResolution()
                // }
            }
        }
    }
}

