import QtQuick
import QtQuick.Controls

Item {
    function testLog() {
        for (var i = 0; i < 10; ++i)

        queryText.text += /*"\n" +*/ queryText.rowCount + "> FOO BAR"
        ++queryText.rowCount
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

                    text: "FOO BAR"
                    wrapMode: Text.Wrap

                    property int rowCount: 1
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
