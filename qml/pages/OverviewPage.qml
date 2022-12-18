import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"

import "../js/functions.js" as Functions

Page {
    id: planPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function connectSlots() {
        Functions.log("[OverviewPage] connect - slots");
        dsbMobileBackend.authTokenAvailable.connect(authTokenResultHandler);
        dsbMobileBackend.requestError.connect(errorResultHandler);
    }

    function disconnectSlots() {
        Functions.log("[OverviewPage] disconnect - slots");
        dsbMobileBackend.authTokenAvailable.disconnect(authTokenResultHandler);
        dsbMobileBackend.requestError.disconnect(errorResultHandler);
    }

    function authTokenResultHandler(result) {
        Functions.log("[OverviewPage] auth token received - " + result);
        // loading = false;
    }

    function errorResultHandler(result) {
        Functions.log("[OverviewPage] error received - " + result);
//        errorInfoLabel.visible = true;
//        errorDetailInfoLabel.text = result;
        // loading = false;
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                //: OverviewPage about menu item
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                //: OverviewPage settings menu item
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                //: OverviewPage settings menu item
                text: qsTr("Refresh")
                onClicked: dsbMobileBackend.getAuthToken(sailDsbSettings.userName, sailDsbSettings.password)
            }
        }


        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                id: planEntriesHeader
                title: qsTr("Overview !!")
            }

            SilicaListView {
                id: planEntriesListView

                height: planPage.height - planEntriesHeader.height - Theme.paddingMedium
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right

                clip: true

                model: ListModel {
                    id: planEntriesModel
                }

                section {
                    property: "theClass" // replace with date!
                    criteria: ViewSection.FullString
                    delegate: SectionHeader {
                        text: section
                    }
                }

                delegate: ListItem {
                    contentHeight: resultItem.height + ( 2 * Theme.paddingMedium )
                    contentWidth: parent.width

                    onClicked: {
                        var selectedPosition = planEntriesModel.get(index);
                        console.log("selection position index : " + index);
                        console.log("position : " + selectedPosition);
                    }

                    Item {
                        id: resultItem
                        width: parent.width
                        height:  resultRowInfo.height + positionSeparator.height
                        y: Theme.paddingMedium

                        Row {
                            id: resultRowInfo
                            width: parent.width - ( 2 * Theme.horizontalPageMargin )
                            spacing: Theme.paddingMedium
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter

                            Column {
                                width: parent.width
                                height: titleRow.height + columnsRow1.height + columnsRow2.height

                                Row {
                                    id: titleRow
                                    width: parent.width
                                    Column {
                                        width: parent.width
                                        Row {
                                            width: parent.width
                                            Text {
                                                id: positionName
                                                width: parent.width * 8 / 10
                                                font.pixelSize: Theme.fontSizeSmall
                                                font.bold: true
                                                color: Theme.primaryColor
                                                elide: Text.ElideRight
                                                text: qsTr("Hour: %1").arg(hour)
                                                textFormat: Text.StyledText
                                            }
                                            Text {
                                                id: positionValue
                                                width: parent.width * 2 / 10
                                                font.pixelSize: Theme.fontSizeSmall
                                                font.bold: true
                                                color: Theme.primaryColor
                                                elide: Text.ElideRight
                                                text: theClass
                                                textFormat: Text.StyledText
                                                horizontalAlignment: Text.AlignRight
                                            }
                                        }
                                    }
                                }

                                Row {
                                    id: columnsRow1
                                    width: parent.width
                                    PlanEntryColumn {
                                        width: parent.width / 2 * 1 - Theme.paddingSmall
                                        //: OverviewPage purchase price
                                        columnLabel: qsTr("Course")
                                        columnValue: course
                                    }
                                    PlanEntryColumn {
                                        width: parent.width / 2 * 1 - Theme.paddingSmall
                                        //: OverviewPage current price
                                        columnLabel: qsTr("Type")
                                        columnValue: type
                                    }
                                }

                                Row {
                                    id: columnsRow2
                                    width: parent.width
                                    PlanEntryColumn {
                                        width: parent.width / 2 * 1 - Theme.paddingSmall
                                        //: OverviewPage pieces/nominales
                                        columnLabel: qsTr("Course new")
                                        columnValue: newCourse
                                    }
                                    PlanEntryColumn {
                                        width: parent.width / 2 * 1 - Theme.paddingSmall
                                        //: OverviewPage purchase price
                                        columnLabel: qsTr("Room")
                                        columnValue: room
                                    }
                                }
                            }

                         }

                        RowSeparator {
                            id: positionSeparator
                            anchors.top : resultRowInfo.bottom
                        }
                     }
                }
            }

        }
    }

    Component.onCompleted: {
        connectSlots();
        dsbMobileBackend.getAuthToken(sailDsbSettings.userName, sailDsbSettings.password);

        var testData = "[{\"data\":[{\"theClass\":\"7a\",\"course\":\"BK\",\"hour\":\"2\",\"newCourse\":\"Geo\",\"room\":\"123\",\"type\":\"Verlegung\"},{\"theClass\":\"9b, 9c\",\"course\":\"Sp w\",\"hour\":\"5 - 6\",\"newCourse\":\"---\",\"room\":\"---\",\"type\":\"Entfall\"},{\"theClass\":\"11\",\"course\":\"e2\",\"hour\":\"3 - 4\",\"newCourse\":\"e2\",\"room\":\"105\",\"type\":\"eigenver. Arbeiten\"}],\"date\":\"25.10.2022 Dienstag, Woche A\"}]";
        var planData = JSON.parse(testData);
        for (var i = 0; i < planData.length; i++) {
            var dayData = planData[i];
            for (var j = 0; j < dayData.data.length; j++) {
                planEntriesModel.append(dayData.data[j]);
                // add each entry mutliple times for scrolling
                planEntriesModel.append(dayData.data[j]);
                planEntriesModel.append(dayData.data[j]);
            }
        }
    }

}
