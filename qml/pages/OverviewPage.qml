import QtQuick 2.0
import Sailfish.Silica 1.0

import "../components"
import "../components/thirdparty"

import "../js/functions.js" as Functions

// TODO when return from settings page - update filter model again

Page {
    id: planPage

    property bool loading : false
    property string authToken : ""
    property var planData

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function connectSlots() {
        Functions.log("[OverviewPage] connect - slots");
        dsbMobileBackend.authTokenAvailable.connect(authTokenResultHandler);
        dsbMobileBackend.plansAvailable.connect(plansResultHandler);
        dsbMobileBackend.requestError.connect(errorResultHandler);
    }

    function disconnectSlots() {
        Functions.log("[OverviewPage] disconnect - slots");
        dsbMobileBackend.authTokenAvailable.disconnect(authTokenResultHandler);
        dsbMobileBackend.plansAvailable.disconnect(plansResultHandler);
        dsbMobileBackend.requestError.disconnect(errorResultHandler);
    }

    function getAuthToken() {
        loading = true;
        dsbMobileBackend.getAuthToken(sailDsbSettings.userName, sailDsbSettings.password);
    }

    function getPlans() {
        dsbMobileBackend.getPlans(authToken);
    }

    function authTokenResultHandler(result) {
        Functions.log("[OverviewPage] auth token received - " + result);
        authToken = result;
        getPlans();
    }

    function addNoStandInEntry(date) {
        var noStandInEntry = {};
        noStandInEntry.theClass = "";
        noStandInEntry.hour = "";
        noStandInEntry.course = "";
        noStandInEntry.type = "";
        noStandInEntry.newCourse = "";
        noStandInEntry.room = "";
        noStandInEntry.room = "";
        noStandInEntry.date = date;
        planEntriesModel.append(noStandInEntry);
    }

    function addPlanDataToModel(planData, filterTokens) {
        for (var i = 0; i < planData.length; i++) {
            var dayData = planData[i];
            var allFiltered = true;
            if (dayData.data.length > 0) {
                for (var j = 0; j < dayData.data.length; j++) {
                    var planDay = dayData.data[j];
                    if (!Functions.isFilterTokenMatch(planDay.theClass, filterTokens)) {
                        // ignore
                    } else {
                        planDay.date = dayData.date;
                        planEntriesModel.append(planDay);
                        allFiltered = false;
                    }
                }
                if (allFiltered) {
                    addNoStandInEntry(dayData.date);
                }
            } else {
                addNoStandInEntry(dayData.date);
            }
        }
    }

    function plansResultHandler(result) {
        Functions.log("[OverviewPage] plan data received - " + result);

        planEntriesModel.clear();

        if (result && result !== "") {
            planData = JSON.parse(result);
            addPlanDataToModel(planData, Functions.getFilterTokens(sailDsbSettings.filter));
        }

        loading = false;
    }

    function errorResultHandler(result) {
        Functions.log("[OverviewPage] error received - " + result);
//        errorInfoLabel.visible = true;
//        errorDetailInfoLabel.text = result;
        loading = false;
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
                onClicked: getAuthToken();
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

// TODO flatten
                section {
                    property: "date"
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
        connectSlots();

        // TODO remove test data
        getAuthToken();

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
