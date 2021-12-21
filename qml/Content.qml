import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels

Item {
    Connections {
        target: dataUpdater

        // Old TableView method
        /*function onLoadNewTable(data) {
            tableView.model = data;
        }*/

        function onLoadNewTable(data) {
            // Clear old data
            listModel.clear();

            for (let item in data) {
                //console.log("Data: ", item, " = ", data[item]);
                listModel.addRow(item, data[item]);
            }

            listView.currentIndex = -1
        }

        function onLoadCitiesToList(data) {
            // Clear old data
            cityModel.clear();

            for (let item in data) {
                cityModel.addRow(data[item]);
            }
        }

        function onLoadCountriesToList(data) {
            // Clear old data
            countryModel.clear();

            for (let item in data) {
                countryModel.addRow(data[item]);
            }
        }

        function onSetUserCountrySignal(countryName) {
            if (countryName === "") {
                userCountry.currentIndex = -1;
                return;
            }

            let found = false;
            for (let i = 0; i < countryModel.count; ++i) {
                let country = countryModel.get(i).text;
                if (country === countryName) {
                    userCountry.currentIndex = i;
                    found = true;
                    break;
                }
            }

            if (found == false) {
                console.log("Did not find country name: ", countryName);
            }
        }

        function onSetUserCitySignal(cityName) {
            if (cityName === "") {
                userCity.currentIndex = -1;
                return;
            }

            let found = false;
            for (let i = 0; i < cityModel.count; ++i) {
                let city = cityModel.get(i).text;
                if (city === cityName) {
                    userCity.currentIndex = i;
                    found = true;
                    break;
                }
            }

            if (found == false) {
                console.log("Did not find city name: ", cityName);
            }
        }

        function onConnectedToDatabase(connected) {
            toggleFields(connected);
        }
    }

    property int databaseTextFieldSpacing: listRectangle.height / 6
    property int defaultTextFontSize: 15

    function clearFields() {
        listView.currentIndex = -1;
        dataUpdater.userFirstname = "";
        dataUpdater.userLastname = "";
        dataUpdater.userEmail = "";
        dataUpdater.userIdField = "";
        dataUpdater.userAddress = "";
        dataUpdater.userPostalCode = "";
        dataUpdater.userPhoneNumber = "";
        dataUpdater.userCityId = 0;
        dataUpdater.userCountryId = 0;
        userCity.currentIndex = -1;
        cityModel.clear();
        userCountry.currentIndex = -1;
    }

    function toggleFields(toggle) {
        listView.enabled = toggle;
        listView.opacity = toggle ? 1.0 : 0.5
        sortButtonId.enabled = toggle;
        sortButtonName.enabled = toggle;
        userFirstName.enabled = toggle;
        userLastName.enabled = toggle;
        userEmail.enabled = toggle;
        userId.enabled = toggle;
        userAddress.enabled = toggle;
        userPostalCode.enabled = toggle;
        userCity.enabled = toggle;
        userCountry.enabled = toggle;
        userPhone.enabled = toggle;
        updateButton.enabled = toggle;
    }

    // Disable all fields when program is started
    Component.onCompleted: toggleFields(false)

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10

        width: parent.width - 20
        height: parent.height - 20

        border.width: 2
        border.color: defaultBorderColor

        color: defaultMainBackgroundColor
        clip: true

        RowLayout {
            id: userListTextLayout
            width: listRectangle.width * 0.85
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 15

            Text {
                width: parent.width / 2
                text: "User Id"
                color: defaultTextColor
                font.pixelSize: defaultTextFontSize - 2
            }

            Text {
                width: parent.width / 2
                text: "Name"
                color: defaultTextColor
                font.pixelSize: defaultTextFontSize - 2
                horizontalAlignment: Text.AlignRight
            }
        }



        Rectangle {
            id: listRectangle

            width: {
                var defaultWidth = parent.width * 0.25
                var minWidth = databaseList.width * 0.5
                return defaultWidth < minWidth ? minWidth : defaultWidth
            }
            height: parent.height / 2

            anchors.left: parent.left
            anchors.top: userListTextLayout.bottom
            anchors.leftMargin: 10
            anchors.topMargin: 10

            color: defaultContentBackgroundColor
            radius: 5

            ListModel {
                id: listModel

                function addRow(id, name) {
                    append({ userId: id, userName: name })
                }
            }

            ListView {
                id: listView
                anchors.fill: parent

                model: listModel

                // Handle highlight change instantly
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 1

                delegate: Item {
                    id: listDelegate
                    width: listView.width
                    height: 40
                    /*height: {
                        var defaultHeight = listView.height * 0.17
                        var minHeight = 30
                        return defaultHeight < minHeight ? minHeight : defaultHeight
                    }*/

                    Text {
                        width: parent.width * 0.3
                        height: parent.height
                        anchors.left: parent.left
                        anchors.leftMargin: 3
                        anchors.top: parent.top
                        anchors.topMargin: 5

                        text: userId
                        font.pixelSize: defaultTextFontSize - 2
                        color: defaultTextColor
                    }

                    Text {
                        width: parent.width * 0.66
                        anchors.right: parent.right
                        anchors.rightMargin: 3
                        anchors.top: parent.top
                        anchors.topMargin: 5

                        text: userName
                        font.pixelSize: defaultTextFontSize - 2
                        horizontalAlignment: Text.AlignRight
                        color: defaultTextColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            listView.currentIndex = index;
                            console.log("index ", index, ", data[1]: ", userName);
                            dataUpdater.loadUserInfo(userId);
                        }
                    }
                }

                highlight: Rectangle { color: defaultBorderColor; radius: 5 }
                focus: true
                clip: true
            }
        }

        Text {
            id: sortText
            anchors.top: listRectangle.bottom
            anchors.topMargin: 20
            anchors.left: listRectangle.left

            text: "Sort By"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        RowLayout {
            width: listRectangle.width
            anchors.top: sortText.bottom
            anchors.topMargin: 10
            anchors.left: sortText.left

            property int sortStyle: 0

            RadioButton {
                id: sortButtonId
                Layout.fillWidth: true
                checked: true
                contentItem: Text {
                    leftPadding: parent.indicator.width + parent.spacing + 5
                    verticalAlignment: Text.AlignVCenter
                    text: "Id"
                    font.pixelSize: defaultTextFontSize
                    color: defaultTextColor
                }

                onClicked: {
                    if (parent.sortStyle === 0)
                        return;

                    parent.sortStyle = 0;
                    dataUpdater.loadSqlTable(parent.sortStyle);
                    clearFields();
                }
            }

            RadioButton {
                id: sortButtonName
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                contentItem: Text {
                    leftPadding: parent.indicator.width + parent.spacing + 5
                    verticalAlignment: Text.AlignVCenter
                    text: "Last Name"
                    font.pixelSize: defaultTextFontSize
                    color: defaultTextColor
                }

                onClicked: {
                    if (parent.sortStyle === 1)
                        return;

                    parent.sortStyle = 1;
                    dataUpdater.loadSqlTable(parent.sortStyle);
                    clearFields();
                }
            }
        }

        Text {
            id: userFirstNameText
            anchors.top: parent.top
            anchors.topMargin: databaseTextFieldSpacing
            anchors.left: listRectangle.right
            anchors.leftMargin: databaseTextFieldSpacing * 1.5

            text: "First Name"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        TextField {
            id: userFirstName
            width: listRectangle.width * 0.8
            anchors.top: userFirstNameText.bottom
            anchors.topMargin: 5
            anchors.left: userFirstNameText.left

            text: dataUpdater.userFirstname
            font.capitalization: Font.AllUppercase
            font.pixelSize: defaultTextFontSize
        }

        Text {
            id: userLastNameText
            anchors.top: userFirstNameText.top
            anchors.left: userFirstName.right
            anchors.leftMargin: databaseTextFieldSpacing

            text: "Last Name"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        TextField {
            id: userLastName
            width: userFirstName.width
            anchors.top: userFirstName.top
            anchors.left: userLastNameText.left

            text: dataUpdater.userLastname
            font.capitalization: Font.AllUppercase
            font.pixelSize: defaultTextFontSize
        }

        Text {
            id: userEmailText
            anchors.top: userFirstName.bottom
            anchors.topMargin: databaseTextFieldSpacing
            anchors.left: userFirstName.left

            text: "Email"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        TextField {
            id: userEmail
            width: userFirstName.width
            anchors.top: userEmailText.bottom
            anchors.topMargin: 5
            anchors.left: userEmailText.left

            text: dataUpdater.userEmail
            font.pixelSize: defaultTextFontSize
        }

        Text {
            id: userIdText
            anchors.top: userEmailText.top
            anchors.left: userLastName.left

            text: "User Id"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        TextField {
            id: userId
            width: userFirstName.width
            anchors.top: userEmail.top
            anchors.left: userLastNameText.left

            text: dataUpdater.userIdField
            font.pixelSize: defaultTextFontSize
        }

        Text {
            id: userAddressText
            anchors.top: userEmail.bottom
            anchors.topMargin: databaseTextFieldSpacing
            anchors.left: userEmail.left

            text: "Address"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        TextField {
            id: userAddress
            width: userFirstName.width
            anchors.top: userAddressText.bottom
            anchors.topMargin: 5
            anchors.left: userAddressText.left

            text: dataUpdater.userAddress
            font.pixelSize: defaultTextFontSize
        }

        Text {
            id: userPostalCodeText
            anchors.top: userAddressText.top
            anchors.left: userId.left

            text: "Postal Code"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        TextField {
            id: userPostalCode
            width: userFirstName.width
            anchors.top: userAddress.top
            anchors.left: userPostalCodeText.left

            text: dataUpdater.userPostalCode
            font.pixelSize: defaultTextFontSize
        }

        Text {
            id: userCityText
            anchors.top: userAddress.bottom
            anchors.topMargin: databaseTextFieldSpacing
            anchors.left: userAddress.left

            text: "City"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        ComboBox {
            id: userCity
            width: userFirstName.width
            anchors.top: userCityText.bottom
            anchors.topMargin: 5
            anchors.left: userCityText.left

            font.pixelSize: defaultTextFontSize

            property int cityId: -1
            property string cityName: ""

            model: ListModel {
                id: cityModel

                function addRow(name) {
                    append({ text: name });
                }
            }

            onCurrentIndexChanged: {
                if (currentIndex == -1) {
                    cityId = -1;
                    cityName = "";
                    return;
                }

                cityName = cityModel.get(currentIndex).text;
                cityId = dataUpdater.getCityIdByName(cityName);

                console.debug("Selected city: " + cityName + ", id: " + cityId);
            }
        }

        Text {
            id: userCountryText
            anchors.top: userCityText.top
            anchors.left: userPostalCode.left

            text: "Country"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        ComboBox {
            id: userCountry
            width: userFirstName.width
            anchors.top: userCity.top
            anchors.left: userCountryText.left

            font.pixelSize: defaultTextFontSize

            property int countryId: -1
            property string countryName: ""

            model: ListModel {
                id: countryModel

                function addRow(name) {
                    append({ text: name });
                }
            }

            onCurrentIndexChanged: {
                if (currentIndex == -1) {
                    countryId = -1;
                    countryName = "";
                    return;
                }

                countryName = countryModel.get(currentIndex).text;
                countryId = dataUpdater.getCountryIdByName(countryName);

                console.debug("Selected country: " + countryName + ", id: " + countryId);

                userCity.currentIndex = -1;
                dataUpdater.loadCitiesForCountryId(countryId);
            }
        }

        Text {
            id: userPhoneText
            anchors.top: userCity.bottom
            anchors.topMargin: databaseTextFieldSpacing
            anchors.left: userCity.left

            text: "Phone Number"
            font.pixelSize: defaultTextFontSize
            color: defaultTextColor
        }

        TextField {
            id: userPhone
            width: userFirstName.width
            anchors.top: userPhoneText.bottom
            anchors.topMargin: 5
            anchors.left: userPhoneText.left

            text: dataUpdater.userPhoneNumber
            font.pixelSize: defaultTextFontSize
        }

        Button {
            id: updateButton
            width: {
                let minWidth = listRectangle.width / 2;
                return implicitWidth < minWidth ? minWidth : implicitWidth;

            }

            anchors.top: userPhone.top
            anchors.left: userCountry.left

            text: "UPDATE USER"
            font.pixelSize: 17

            contentItem: Text {
                text: updateButton.text
                font: updateButton.text
                color: defaultTextColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: defaultContentBackgroundColor
            }

            onClicked: {
                if (listView.currentIndex == -1) {
                    console.log("No user selected");
                    return;
                }

                if (userCity.cityId < 0 || userCountry.countryId < 0) {
                    console.log("City or country below 0, aborting");
                    return;
                }

                dataUpdater.userFirstname = userFirstName.text.toUpperCase();
                dataUpdater.userLastname = userLastName.text.toUpperCase();
                dataUpdater.userEmail = userEmail.text;
                dataUpdater.userAddress = userAddress.text;
                dataUpdater.userPostalCode = userPostalCode.text;
                dataUpdater.userCityId = userCity.cityId;
                dataUpdater.userCountryId = userCountry.countryId;
                dataUpdater.userPhoneNumber = userPhone.text;

                if (dataUpdater.updateUser()) {
                    let newName = dataUpdater.userLastname + ", " + dataUpdater.userFirstname;
                    listModel.setProperty(listView.currentIndex, "userName", newName);
                }
            }
        }


        // Old TableView
        /*TableView {
            id: tableView
            anchors.fill: parent
            anchors.margins: 2

            columnSpacing: 1
            rowSpacing: 1
            clip: true

            //columnWidthProvider: 50
            //rowHeightProvider: 50

            //model: tableModel

            // Vertical scroll bar
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            // Horizontal scroll bar
            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            delegate: TextInput {
                id: textInput
                text: model.modelData
                padding: 12
                selectByMouse: true

                onAccepted: model.display = text

                Rectangle {
                    anchors.fill: parent
                    color: textInput.focus ? defaultContentBackgroundColor : "#FFFFFF"
                    focus: true
                    z: -1
                }
            }

//            Row {
//                id: columnsHeader
//                y: tableView.contentY
//                z: 2
//                Repeater {
//                    model: tableView.columns > 0 ? tableView.columns : 1
//                    Label {
//                        width: tableView.columnWidthProvider
//                        height: tableView.rowHeightProvider
//                        text: tableModel.headerData(modelData, Qt.Horizontal)
//                        color: '#aaaaaa'
//                        font.pixelSize: 15
//                        padding: 10
//                        verticalAlignment: Text.AlignVCe
//                        background: Rectangle { color: "#333333" }
//                    }
//                }
//            }
        }*/
    }
}
