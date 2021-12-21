import QtQuick
import QtQuick.Controls

Item {
    Connections {
        target: dataUpdater

        function onConnectedToDatabase(connected) {
            databaseHostname.enabled = !connected;
            databaseUsername.enabled = !connected;
            databasePassword.enabled = !connected;
            databaseDb.enabled = !connected;
            databasePort.enabled = !connected;
        }
    }

    property int defaultFontSize: 14

    // Outer background
    Rectangle {
        anchors.fill: parent
        color: defaultMainBackgroundColor

        // Inner background
        Rectangle {
            id: databaseInnerBackground
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10

            width: parent.width - 20 - rightBorder.width
            height: parent.height - 20
            color: defaultContentBackgroundColor

            border.width: 2
            border.color: defaultBorderColor

            clip: true

            // The actual content
            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                color: databaseInnerBackground.color

                Text {
                    id: databaseHostnameText
                    anchors.top: parent.top
                    anchors.left: parent.left

                    text: "Hostname"
                    font.pixelSize: defaultFontSize
                    color: defaultTextColor
                }

                TextField {
                    id: databaseHostname
                    width: parent.width * 0.8
                    anchors.top: databaseHostnameText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05

                    text: dataUpdater.dbHostname
                    font.pixelSize: defaultFontSize
                }

                Text {
                    id: databaseUsernameText
                    anchors.top: databaseHostname.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Username"
                    font.pixelSize: defaultFontSize
                    color: defaultTextColor
                }

                TextField {
                    id: databaseUsername
                    width: parent.width * 0.8
                    anchors.top: databaseUsernameText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05

                    text: dataUpdater.dbUsername
                    font.pixelSize: defaultFontSize
                }

                Text {
                    id: databasePasswordText
                    anchors.top: databaseUsername.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Password"
                    font.pixelSize: defaultFontSize
                    color: defaultTextColor
                }

                TextField {
                    id: databasePassword
                    width: parent.width * 0.8
                    anchors.top: databasePasswordText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05

                    text: dataUpdater.dbPassword
                    font.pixelSize: defaultFontSize
                    echoMode: TextInput.Password
                }

                Text {
                    id: databaseDbText
                    anchors.top: databasePassword.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Database"
                    font.pixelSize: defaultFontSize
                    color: defaultTextColor
                }

                TextField {
                    id: databaseDb
                    width: parent.width * 0.8
                    anchors.top: databaseDbText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05

                    text: dataUpdater.dbDatabase
                    font.pixelSize: defaultFontSize
                }

                Text {
                    id: databasePortText
                    anchors.top: databaseDb.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Port"
                    font.pixelSize: defaultFontSize
                    color: defaultTextColor
                }

                TextField {
                    id: databasePort
                    width: parent.width * 0.8
                    anchors.top: databasePortText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05

                    text: dataUpdater.dbPort
                    font.pixelSize: defaultFontSize
                }

                /*Button {
                    width: parent.width * 0.3
                    height: width / 2
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    text: "Query"

                    onClicked: queryWindow.testLog()
                }*/

                Button {
                    id: connectButton
                    width: databaseHostname.width * 0.5
                    anchors.top: databasePort.bottom
                    anchors.topMargin: 40
                    anchors.horizontalCenter: databasePort.horizontalCenter
                    text: "CONNECT"
                    font.pixelSize: defaultFontSize

                    contentItem: Text {
                        text: connectButton.text
                        font: connectButton.text
                        color: defaultTextColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        color: defaultMainBackgroundColor
                    }

                    onClicked: {
                        // Send database connection info to Qt
                        dataUpdater.dbHostname = databaseHostname.text
                        dataUpdater.dbUsername = databaseUsername.text
                        dataUpdater.dbPassword = databasePassword.text
                        dataUpdater.dbDatabase = databaseDb.text
                        dataUpdater.dbPort = databasePort.text

                        dataUpdater.loadSqlTable(0)
                    }
                }
            }
        }

        // Right border
        Rectangle {
            id: rightBorder

            width: 10
            height: parent.height
            anchors.right: parent.right
            color: defaultContentBackgroundColor
        }
    }
}
