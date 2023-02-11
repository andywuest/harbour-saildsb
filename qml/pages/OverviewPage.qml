import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../components/thirdparty"

import "../js/functions.js" as Functions

Page {
    id: planPage

    property bool loading : false
    property var planData
    property bool hasCredentials : false

    allowedOrientations: Orientation.Portrait

    function receiveCredentialsChanged() {
        Functions.log("[OverviewPage] - credendtials changed received.");
        loading = true;
        planPage.hasCredentials = app.hasCredentials();
        app.getAuthToken();
    }

    function receivePlanDataChanged(result, error, date) {
        Functions.log("[OverviewPage] - data has changed, result : " + result
                      + ", error " + error + ", date : " + date)
        if (result) {
            planPage.planData = result;
            addPlanDataToModel();
        } else if (error) {
            planEntriesHeader.description = "";
            planUpdateNotification.show(error);
        }

        loading = false;
    }

    function addNoStandInEntry(dateString) {
        var noStandInEntry = {};
        noStandInEntry.theClass = "";
        noStandInEntry.hour = "";
        noStandInEntry.course = "";
        noStandInEntry.type = "";
        noStandInEntry.newCourse = "";
        noStandInEntry.room = "";
        noStandInEntry.room = "";
        noStandInEntry.dateString = dateString;
        planEntriesModel.append(noStandInEntry);
    }

    function addPlanDataToModel() {
        Functions.log("[OverviewPage] - addPlanDataToModel called.");
        planEntriesModel.clear();

        var filterTokens = Functions.getFilterTokens(sailDsbSettings.filter)
        for (var i = 0; i < planPage.planData.length; i++) {
            var dayData = planPage.planData[i];
            var allFiltered = true;
            if (dayData.data.length > 0) {
                for (var j = 0; j < dayData.data.length; j++) {
                    var planDay = dayData.data[j];
                    if (!Functions.isFilterTokenMatch(planDay.theClass, filterTokens)) {
                        // ignore
                    } else {
                        planDay.dateString = dayData.dateString;
                        planEntriesModel.append(planDay);
                        allFiltered = false;
                    }
                    planEntriesHeader.description = dayData.title;
                }
                if (allFiltered) {
                    addNoStandInEntry(dayData.dateString);
                }
            } else {
                addNoStandInEntry(dayData.dateString);
            }
        }
    }

    AppNotification {
        id: planUpdateNotification
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
                onClicked: {
                    var settingsPage = pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
                    settingsPage.applyChangedFilter.connect(addPlanDataToModel);
                    settingsPage.crendentialsChanged.connect(receiveCredentialsChanged);
                }
            }
            MenuItem {
                //: OverviewPage settings menu item
                text: qsTr("Refresh")
                onClicked: app.getAuthToken();
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
                title: qsTr("Plans")
            }

            Label {
                id: noCredentialsLabel
                horizontalAlignment: Text.AlignHCenter
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                visible: !planPage.hasCredentials

                wrapMode: Text.Wrap
                textFormat: Text.RichText
                text: qsTr("Please provide valid credentials via the Settings to see the plans.")
            }

            SilicaListView {
                id: planEntriesListView

                height: planPage.height - planEntriesHeader.height - Theme.paddingMedium
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right
                visible: !noCredentialsLabel.visible

                clip: true

                model: ListModel {
                    id: planEntriesModel
                }

// TODO flatten
                section {
                    property: "dateString"
                    criteria: ViewSection.FullString
                    delegate: SectionHeader {
                        text: section
                    }
                }

                delegate: ListItem {
                    id: wrapper
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

                        Text {
                            id: noDataText
                            height: resultItem.height
                            width: planEntriesListView.width
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            visible: !hour
                            font.pixelSize: Theme.fontSizeHuge
                            font.bold: false
                            color: Theme.highlightColor

                             text: qsTr("No stand-in")
                             transform: Rotation {
                                     // origin: Item.Center
                                     origin.x: noDataText.width / 2;
                                     origin.y: noDataText.height / 2;
                                     angle: 15
                             }
                        }


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
                                                text: Functions.resolveText(hour, qsTr("Hour: %1").arg(hour))
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
                                        columnLabel: Functions.resolveText(hour, qsTr("Course"))
                                        columnValue: course
                                    }
                                    PlanEntryColumn {
                                        width: parent.width / 2 * 1 - Theme.paddingSmall
                                        //: OverviewPage current price
                                        columnLabel: Functions.resolveText(hour, qsTr("Type"))
                                        columnValue: type
                                    }
                                }

                                Row {
                                    id: columnsRow2
                                    width: parent.width
                                    PlanEntryColumn {
                                        width: parent.width / 2 * 1 - Theme.paddingSmall
                                        //: OverviewPage pieces/nominales
                                        columnLabel: Functions.resolveText(hour, qsTr("Course new"))
                                        columnValue: newCourse
                                    }
                                    PlanEntryColumn {
                                        width: parent.width / 2 * 1 - Theme.paddingSmall
                                        //: OverviewPage purchase price
                                        columnLabel: Functions.resolveText(hour, qsTr("Room"))
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
        app.planDataChanged.connect(receivePlanDataChanged)
        loading = true;

        planPage.hasCredentials = app.hasCredentials();

        Functions.log("[OverviewPage.onCompleted] - hasCredentials : " + planPage.hasCredentials);

        // TODO remove test data
        app.getAuthToken();

//        var testData = "[{\"data\":[{\"theClass\":\"7a\",\"course\":\"BK\",\"hour\":\"2\",\"newCourse\":\"Geo\",\"room\":\"123\",\"type\":\"Verlegung\"},{\"theClass\":\"9b, 9c\",\"course\":\"Sp w\",\"hour\":\"5 - 6\",\"newCourse\":\"---\",\"room\":\"---\",\"type\":\"Entfall\"},{\"theClass\":\"11\",\"course\":\"e2\",\"hour\":\"3 - 4\",\"newCourse\":\"e2\",\"room\":\"105\",\"type\":\"eigenver. Arbeiten\"}],\"date\":\"25.10.2022 Dienstag, Woche A\"}]";
//        var planData = JSON.parse(testData);
//        for (var i = 0; i < planData.length; i++) {
//            var dayData = planData[i];
//            for (var j = 0; j < dayData.data.length; j++) {
//                planEntriesModel.append(dayData.data[j]);
//                // add each entry mutliple times for scrolling
//                planEntriesModel.append(dayData.data[j]);
//                planEntriesModel.append(dayData.data[j]);
//            }
//        }
    }

    LoadingIndicator {
        id: loginLoadingIndicator
        visible: loading
        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: loading ? 1 : 0
        height: parent.height
        width: parent.width
    }

}
