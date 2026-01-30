import QtQuick 2.15
import QtQuick.Shapes 1.15

Shape {
    // anchors.fill: parent
    id: shape
    enum Direction {
        TopRight,     // 原始位置
        BottomRight,  // 旋转90度
        BottomLeft,   // 旋转180度
        TopLeft       // 旋转270度
    }

    property int direction: RadiusRemainedPart.BottomRight
    property color color: "black"
    property real borderWidth: 0
    property color borderColor: "transparent"

    height: width

    layer.enabled: true
    layer.smooth: true
    layer.textureSize: Qt.size(shape.width * 2, shape.height * 2)  // 2倍超采样
    // transformOrigin: Item.Center

    rotation: {
        switch(direction) {
            case RadiusRemainedPart.TopRight: return 270
            case RadiusRemainedPart.BottomRight: return 0
            case RadiusRemainedPart.BottomLeft: return 90
            case RadiusRemainedPart.TopLeft: return 180
        }
    }


    ShapePath {
        fillColor: color
        strokeWidth: 0



        startX: width; startY: 0
        PathArc {
            x: 0; y: height
            radiusX: width
            radiusY: height
            direction: PathArc.Clockwise
        }
        PathLine{
            x: width; y:height
        }
        PathLine{
            x:width; y:0
        }
    }

}

