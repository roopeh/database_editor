import QtQuick 2.15
import QtQuick.Controls 2.15

Menu {
    delegate: MenuItem {
        id: menuItem

        contentItem: Text {
            text: menuItem.text
            font: menuItem.font
            color: "#ababab"
        }

        background: Rectangle {
            color: menuItem.highlighted ? "#577180" : "#3b4d57"
        }
    }
}
