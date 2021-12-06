import QtQuick 2.15

Item {
    Rectangle {
        anchors.fill: parent
        color: "#212b30"

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10

            width: parent.width - 20 - rightBorder.width
            height: parent.height - 20
            color: "#3b4d57"

            border.width: 2
            border.color: "#577180"
        }

        // Right border
        Rectangle {
            id: rightBorder

            width: 10
            height: parent.height
            anchors.right: parent.right
            color: "#3b4d57"
        }
    }
}
