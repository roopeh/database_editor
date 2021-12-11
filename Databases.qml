import QtQuick
import QtQuick.Controls

Item {

    // Connection getter functions
    function getDbHostname() { return databaseHostname.text }
    function getDbUsername() { return databaseUsername.text }
    function getDbPassword() { return databasePassword.text }
    function getDbDatabase() { return databaseDb.text }
    function getDbPort() { return databasePort.text }

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
                    color: defaultTextColor
                }

                TextField {
                    id: databaseHostname
                    width: parent.width * 0.8
                    anchors.top: databaseHostnameText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05
                }

                Text {
                    id: databaseUsernameText
                    anchors.top: databaseHostname.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Username"
                    color: defaultTextColor
                }

                TextField {
                    id: databaseUsername
                    width: parent.width * 0.8
                    anchors.top: databaseUsernameText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05
                }

                Text {
                    id: databasePasswordText
                    anchors.top: databaseUsername.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Password"
                    color: defaultTextColor
                }

                TextField {
                    id: databasePassword
                    width: parent.width * 0.8
                    anchors.top: databasePasswordText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05

                    echoMode: TextInput.Password
                }

                Text {
                    id: databaseDbText
                    anchors.top: databasePassword.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Database"
                    color: defaultTextColor
                }

                TextField {
                    id: databaseDb
                    width: parent.width * 0.8
                    anchors.top: databaseDbText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05
                }

                Text {
                    id: databasePortText
                    anchors.top: databaseDb.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left

                    text: "Port"
                    color: defaultTextColor
                }

                TextField {
                    id: databasePort
                    width: parent.width * 0.8
                    anchors.top: databasePortText.bottom
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    anchors.leftMargin: width * 0.05
                }

                Button {
                    width: parent.width * 0.3
                    height: width / 2
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    text: "Query"

                    onClicked: queryWindow.testLog()
                }

                Button {
                    width: parent.width * 0.3
                    height: width / 2
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    text: "Data"

                    onClicked: dataUpdater.loadSqlTable()
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
