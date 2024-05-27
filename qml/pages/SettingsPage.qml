import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

// QTBUG-34418
import "."

import "../js/functions.js" as Functions
import "../js/constants.js" as Constants

Page {
    id: settingsPage
    signal applyChangedFilter()
    signal credentialsChanged()

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            Functions.log("[SettingsPage] store settings!");
            var filterChanged = (sailDsbSettings.filter !== filterTextField.text);
            var credentialsChanged = (sailDsbSettings.userName !== userNameTextField.text
                                      || sailDsbSettings.password !== passwordTextField.text);
            sailDsbSettings.userName = userNameTextField.text;
            sailDsbSettings.password = passwordTextField.text;
            sailDsbSettings.filter = filterTextField.text;
            sailDsbSettings.schoolId = schoolComboBox.currentIndex
            sailDsbSettings.sync();
            if (credentialsChanged) {
                Functions.log("[SettingsPage] Credentials have changed");
                credentialsChanged();
            } else if (filterChanged) {
                Functions.log("[SettingsPage] Filter has changed to " + filterTextField.text);
                applyChangedFilter();
            }
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
            spacing: Theme.paddingSmall

            PageHeader {
                //: SettingsPage settings title
                title: qsTr("Settings")
            }

            ComboBox {
                id: schoolComboBox
                //: SettingsPage state
                label: qsTr("School")
                currentIndex: sailDsbSettings.schoolId
                //: SettingsPage region description
                description: qsTr("Select the school")
                menu: ContextMenu {
                    id: schoolMenu
                    MenuItem {
                        readonly property int value: Constants.GSG_SILLENBUCH
                        text: qsTr("GSG Sillenbuch");
                    }
                    MenuItem {
                        readonly property int value: Constants.RS_HUERTH
                        text: qsTr("Realschule Hürth")
                    }
                }
            }

            SectionHeader {
                //: SettingsPage section user name
                text: qsTr("DSBMobile Credentials")
            }

            TextField {
                id: userNameTextField
                width: parent.width
                text: sailDsbSettings.userName
            }

            TextField {
                id: passwordTextField
                width: parent.width
                text: sailDsbSettings.password
            }

            SectionHeader {
                //: SettingsPage filter
                text: qsTr("Filter")
            }

            TextField {
                id: filterTextField
                width: parent.width
                text: sailDsbSettings.filter
            }
        }

    }

//194962/plan

}
