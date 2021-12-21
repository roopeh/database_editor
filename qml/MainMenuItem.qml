import QtQuick
import QtQuick.Controls

Menu {
    delegate: MenuItem {
        id: menuItem

        contentItem: Text {
            text: menuItem.text
            font: menuItem.font
            color: defaultTextColor
        }

        background: Rectangle {
            color: menuItem.highlighted ? defaultBorderColor : defaultContentBackgroundColor
        }
    }
}
