import QtQuick 2.15
import Qt.labs.qmlmodels 1.0

Item {
    Rectangle {
        anchors.fill: parent
        color: "#212b30"

        TableView {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10

            width: parent.width - 20
            height: parent.height - 20

            columnSpacing: 1
            rowSpacing: 1
            clip: true

            model: TableModel {
                TableModelColumn { display: "test1" }
                TableModelColumn { display: "test2" }
                TableModelColumn { display: "test3" }
                TableModelColumn { display: "test4" }
                TableModelColumn { display: "test5" }

                // TODO: test content
                rows: [
                    {
                        test1: false,
                        test2: 1,
                        test3: "Apple",
                        test4: "Granny Smith",
                        test5: 1.50
                    },
                    {
                        test1: true,
                        test2: 4,
                        test3: "Orange",
                        test4: "Navel",
                        test5: 2.50
                    },
                    {
                        test1: false,
                        test2: 1,
                        test3: "Banana",
                        test4: "Cavendish",
                        test5: 3.50
                    }
                ]
            }

            delegate: TextInput {
                text: model.display
                padding: 12
                selectByMouse: true

                onAccepted: model.display = text

                Rectangle {
                    anchors.fill: parent
                    color: "#3b4d57"
                    z: -1
                }
            }
        }
    }
}
