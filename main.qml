import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.15

ApplicationWindow {
    id: mainWindowRoot
    visible: true
    width: 1280
    height: 720
    visibility: Window.Windowed

    Component.onCompleted: {
        setX(Screen.width / 2 - width / 2)
        setY(Screen.height / 2 - height / 2)
    }

    Item {
        id: mainWindow
        anchors.fill: parent

        Item {
            id: mainBackground
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: "#212b30"
            }
        }
    }

    // Menu bar
    menuBar: MainMenuBar {
        id: mainMenuBar
    }

    // Databases
    Databases {
        id: databaseList
        width: 300
        height: parent.height - mainMenuBar.height - queryWindow.height

        anchors.top: mainMenuBar.bottom
        anchors.bottom: queryWindow.top
        anchors.left: parent.left
    }

    // Content
    Content {
        id: contentWindow
        width: parent.width - databaseList.width
        height: parent.height - mainMenuBar.height - queryWindow.height

        anchors.top: mainMenuBar.bottom
        anchors.left: databaseList.right
        anchors.bottom: queryWindow.top
    }

    // Query window
    QueryWindow {
        id: queryWindow
        width: parent.width
        height: parent.height * 0.25

        anchors.bottom: parent.bottom
    }
}
