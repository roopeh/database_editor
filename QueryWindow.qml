import QtQuick 2.15

Item {
    Rectangle {
        anchors.fill: parent
        color: "#212b30"

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: topBorder.bottom
            anchors.topMargin: 10

            width: parent.width - 20
            height: parent.height - 20 - topBorder.height
            color: "#3b4d57"

            border.width: 2
            border.color: "#577180"
        }

        // Top border
        Rectangle {
            id: topBorder

            width: parent.width - 20
            height: 10
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            color: "#3b4d57"
        }
    }
}
