import QtQuick 2.15
import QtQuick.Controls 2.15

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
