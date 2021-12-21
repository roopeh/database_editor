import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    Connections {
        target: dataUpdater

        function onConnectedToDatabase(connected) {
            layoutMethod.visible = connected
        }
    }

    Component.onCompleted: layoutMethod.visible = false

    property int tableMethod: 0

    Rectangle {
        anchors.fill: parent
        color: defaultContentBackgroundColor

        RowLayout {
            id: layoutMethod
            anchors.fill: parent
            anchors.topMargin: 5
            anchors.leftMargin: 50
            anchors.rightMargin: 50

            RadioButton {
                id: buttonAddMethod
                checked: true

                contentItem: Text {
                    leftPadding: parent.indicator.width + parent.spacing + 5
                    verticalAlignment: Text.AlignVCenter
                    text: "Add New User"
                    font.pixelSize: 14
                    color: defaultTextColor
                }

                onClicked: {
                    if (tableMethod === 0)
                        return;

                    tableMethod = 0;
                    contentWindow.changeTableMethod(tableMethod, true);
                }
            }

            RadioButton {
                id: buttonUpdateMethod

                contentItem: Text {
                    leftPadding: parent.indicator.width + parent.spacing + 5
                    verticalAlignment: Text.AlignVCenter
                    text: "Update User"
                    font.pixelSize: 14
                    color: defaultTextColor
                }

                onClicked: {
                    if (tableMethod === 1)
                        return;

                    tableMethod = 1;
                    contentWindow.changeTableMethod(tableMethod, true);
                }
            }

            RadioButton {
                id: buttonRemoveMethod

                contentItem: Text {
                    leftPadding: parent.indicator.width + parent.spacing + 5
                    verticalAlignment: Text.AlignVCenter
                    text: "Remove User"
                    font.pixelSize: 14
                    color: defaultTextColor
                }

                onClicked: {
                    if (tableMethod === 2)
                        return;

                    tableMethod = 2;
                    contentWindow.changeTableMethod(tableMethod, true);
                }
            }
        }
    }
}
