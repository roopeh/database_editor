import QtQuick
import QtQuick.Controls

MenuBar {
    // Menus
    MainMenuItem {
        title: qsTr("File")
        Action {
            text: qsTr("Quit")
            onTriggered: Qt.quit(); }
    }

    MainMenuItem {
        id: barMenu
        title: qsTr("Views")
        Action { text: qsTr("Connection Window") }
    }

    delegate: MenuBarItem {
        id: menuBarItem

        contentItem: Text {
            text: menuBarItem.text
            font: menuBarItem.font
            color: defaultTextColor
        }

        background: Rectangle {
            implicitWidth: 80
            color: menuBarItem.highlighted ? defaultBorderColor : defaultContentBackgroundColor
        }
    }

    background: Rectangle {
        color: defaultContentBackgroundColor
    }
}
