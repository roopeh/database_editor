import QtQuick 2.15
import QtQuick.Controls 2.15

MenuBar {
    // Menus
    MainMenuItem {
        title: qsTr("Foo")
        Action { text: qsTr("Bar1") }
        Action { text: qsTr("Bar2") }
        Action {
            text: qsTr("Bar3")
            onTriggered: Qt.quit(); }
    }

    MainMenuItem {
        id: barMenu
        title: qsTr("Bar")
        Action { text: qsTr("Foo1") }
        Action { text: qsTr("Foo2") }
        Action { text: qsTr("Foo3") }
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