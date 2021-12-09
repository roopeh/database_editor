import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.qmlmodels 1.0

Item {
    Connections {
        target: dataUpdater

        // Old TableView method
        /*function onLoadNewTable(data) {
            tableView.model = data;
        }*/

        function onLoadNewTable(data) {
            // Clear old data
            listModel.clear();

            console.log("Cleared");

            for (var item in data) {
                console.log("Data: ", item, " = ", data[item]);
                listModel.addRow(item, data[item]);
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10

        width: parent.width - 20
        height: parent.height - 20

        border.width: 2
        border.color: "#577180"

        color: "#212b30"

        Rectangle {
            id: listRectangle

            width: 200
            height: 200

            anchors.left: parent.left
            anchors.top: parent.top

            ListModel {
                id: listModel

                function addRow(id, name) {
                    append({ userId: id, userName: name })
                }
            }

            ListView {
                id: listView
                anchors.fill: parent

                model: listModel

                // Handle highlight change instantly
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 1

                delegate: Item {
                    id: listDelegate
                    width: listView.width
                    height: 40

                    Text {
                        text: userId
                        anchors.left: parent.left
                    }

                    Text {
                        text: userName
                        anchors.right: parent.right
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            listView.currentIndex = index;
                            console.log("index ", index, ", data[1]: ", userName);
                        }
                    }
                }

                highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
                focus: true
                clip: true
            }
        }

        // Old TableView
        /*TableView {
            id: tableView
            anchors.fill: parent
            anchors.margins: 2

            columnSpacing: 1
            rowSpacing: 1
            clip: true

            //columnWidthProvider: 50
            //rowHeightProvider: 50

            //model: tableModel

            // Vertical scroll bar
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            // Horizontal scroll bar
            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            delegate: TextInput {
                id: textInput
                text: model.modelData
                padding: 12
                selectByMouse: true

                onAccepted: model.display = text

                Rectangle {
                    anchors.fill: parent
                    color: textInput.focus ? "#3b4d57" : "#FFFFFF"
                    focus: true
                    z: -1
                }
            }

//            Row {
//                id: columnsHeader
//                y: tableView.contentY
//                z: 2
//                Repeater {
//                    model: tableView.columns > 0 ? tableView.columns : 1
//                    Label {
//                        width: tableView.columnWidthProvider
//                        height: tableView.rowHeightProvider
//                        text: tableModel.headerData(modelData, Qt.Horizontal)
//                        color: '#aaaaaa'
//                        font.pixelSize: 15
//                        padding: 10
//                        verticalAlignment: Text.AlignVCe
//                        background: Rectangle { color: "#333333" }
//                    }
//                }
//            }
        }*/
    }
}
