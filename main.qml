import QtQuick 2.15
import QtQuick.Controls 2.12
import QtQuick.Window 2.15

import DataUpdater 0.1

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

    // Qt C++ classes
    DataUpdater { id: dataUpdater }

    Rectangle {
        id: mainWindowBackground
        anchors.fill: parent

        color: "#212b30"
    }

    // Menu bar
    Rectangle {
        id: menuBar
        width: parent.width
        height: mainMenuBar.height

        // Connection bar
        MainMenuBar {
            id: mainMenuBar
            width: 300
        }

        // Table bar
        TableBar {
            id: tableBar
            width: parent.width - mainMenuBar.width
            height: mainMenuBar.height

            anchors.top: parent.top
            anchors.left: mainMenuBar.right
        }
    }

    // Databases
    Databases {
        id: databaseList
        width: mainMenuBar.width
        height: parent.height - menuBar.height - queryWindow.height

        anchors.top: menuBar.bottom
        anchors.bottom: queryWindow.top
        anchors.left: parent.left

        MouseArea {
            anchors.fill: parent

            onClicked: { dataUpdater.loadSqlTable() }
        }
    }

    // Content
    Content {
        id: contentWindow
        width: parent.width - databaseList.width
        height: parent.height - menuBar.height - queryWindow.height

        anchors.top: menuBar.bottom
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
