import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

// QTBUG-34418
import "."

import "../js/functions.js" as Functions

Page {
    id: settingsPage

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            Functions.log("[SettingsPage] store settings!");
            sailDsbSettings.userName = userNameTextField.text;
            sailDsbSettings.password = passwordTextField.text;
            sailDsbSettings.sync();
        }
    }

    SilicaFlickable {
        id: settingsFlickable
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: settingsColumn.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: settingsColumn
            width: settingsPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                //: SettingsPage settings title
                title: qsTr("Settings")
            }

            // TODO does not loog good with section headers
            SectionHeader {
                //: SettingsPage section user name
                text: qsTr("User name")
            }

            TextField {
                id: userNameTextField
                width: parent.width
                text: sailDsbSettings.userName
            }

            // TODO does not loog good with section headers
            SectionHeader {
                //: SettingsPage section password
                text: qsTr("Password")
            }

            TextField {
                id: passwordTextField
                width: parent.width
                text: sailDsbSettings.password
            }

        }

    }

}
