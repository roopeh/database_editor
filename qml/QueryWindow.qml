import QtQuick
import QtQuick.Controls

Item {
    Connections {
        target: dataUpdater

        function onAppendNewLogMessage(message) {
            queryText.text += message + "<br>";

            scrollView.scrollToBottom();
        }
    }

    // Outer background
    Rectangle {
        anchors.fill: parent
        color: defaultMainBackgroundColor

        // Inner background
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: topBorder.bottom
            anchors.topMargin: 10

            width: parent.width - 20
            height: parent.height - 20 - topBorder.height
            color: defaultContentBackgroundColor

            border.width: 2
            border.color: defaultBorderColor

            // The actual content
            ScrollView {
                id: scrollView
                width: parent.width
                contentWidth: scrollViewScrollBar.visible ? width - scrollViewScrollBar.width : width
                contentHeight: queryText.height
                anchors.fill: parent
                anchors.margins: 10

                ScrollBar.vertical: ScrollBar {
                    id: scrollViewScrollBar
                    anchors.right: parent.right
                    height: parent.height
                }

                // Disable horizontal scroll bar
                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }

                Text {
                    id: queryText
                    width: scrollView.contentWidth

                    text: ""
                    color: defaultTextColor
                    font.pixelSize: 17
                    textFormat: TextEdit.RichText
                    wrapMode: Text.Wrap
                }

                function scrollToBottom() {
                    ScrollBar.vertical.position = 1.0 - ScrollBar.vertical.size;
                }
            }
        }

        // Top border
        Rectangle {
            id: topBorder

            width: parent.width - 20
            height: 10
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            color: defaultContentBackgroundColor
        }
    }
}
