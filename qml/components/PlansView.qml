import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0

// QTBUG-34418
import "."

import "../js/constants.js" as Constants
import "../js/functions.js" as Functions

import "../components"
import "../components/thirdparty"

SilicaFlickable {
    id: plansViewFlickable

    property bool loading : false
    property var planData
    property bool hasCredentials : false

    property string row1Column1Label: ""
    property string row1Column2Label: ""
    property string row1Column3Label: ""
    property string row2Column1Label: ""
    property string row2Column2Label: ""
    property string row3Column1Label: ""
    property string row3Column2Label: ""
    property bool row3Visible: false

    anchors.fill: parent
    contentWidth: parent.width
    contentHeight: column.height

    function receiveCredentialsChanged() {
        Functions.log("[PlansView] - credendtials changed received.");
        loading = true;
        plansViewFlickable.hasCredentials = app.hasCredentials();
        app.getAuthToken();
    }

    function receivePlanDataChanged(result, error, date) {
        Functions.log("[PlansView] - data has changed, result : " + result
                      + ", error " + error + ", date : " + date)
        if (result) {
            plansViewFlickable.planData = result;
            addPlanDataToModel();
        } else if (error) {
            planEntriesHeader.description = "";
            planUpdateNotification.show(error);
        }

        loading = false;
    }

    function receiveLoadingStateChanged(isLoading) {
        Functions.log("[PlansView] - isLoading changed, result : " + isLoading);
        plansViewFlickable.loading = isLoading;
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
        Functions.log("[PlansView] - addPlanDataToModel called.");
        Functions.log("[PlansView] - schoolId : " + sailDsbSettings.schoolId);
        planEntriesModel.clear();

        var filterTokens = Functions.getFilterTokens(sailDsbSettings.filter)
        for (var i = 0; i < plansViewFlickable.planData.length; i++) {
            var dayData = plansViewFlickable.planData[i];
            var allFiltered = true;

            planEntriesHeader.description = dayData.title;

            if (dayData.data.length > 0 && dayData.labels) {
                row1Column1Label = dayData.labels.row1_column1;
                row1Column2Label = dayData.labels.row1_column2;
                row1Column3Label = dayData.labels.row1_column3;
                row2Column1Label = dayData.labels.row2_column1;
                row2Column2Label = dayData.labels.row2_column2;
                if (Functions.hasSchoolThreeRows(sailDsbSettings.schoolId)) {
                    row3Visible = true;
                    row3Column1Label = dayData.labels.row3_column1;
                    row3Column2Label = dayData.labels.row3_column2;
                } else {
                    row3Visible = false;
                    row3Column1Label = "";
                    row3Column2Label = "";
                }
            }

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

                }
                if (allFiltered) {
                    addNoStandInEntry(dayData.dateString);
                }
            } else {
                addNoStandInEntry(dayData.dateString);
            }
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
            visible: !plansViewFlickable.hasCredentials

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: qsTr("Please provide valid credentials via the Settings to see the plans.")
        }

        SilicaListView {
            id: planEntriesListView

            height: plansViewFlickable.height - planEntriesHeader.height - Theme.paddingMedium
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !noCredentialsLabel.visible

            clip: true

            model: ListModel {
                id: planEntriesModel
            }

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
                                   + (row3Visible ? columnsRow3.height : 0)

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
                                    width: parent.width / 3 * 1 - Theme.paddingSmall
                                    //: OverviewPage course
                                    columnLabel: row1Column1Label
                                    columnValue: Functions.toStr(row1_column1)
                                }
                                PlanEntryColumn {
                                    width: parent.width / 3 * 1 - Theme.paddingSmall
                                    //: OverviewPage type
                                    columnLabel: row1Column2Label
                                    columnValue: Functions.toStr(row1_column2)
                                }
                                PlanEntryColumn {
                                    width: parent.width / 3 * 1 - Theme.paddingSmall
                                    //: OverviewPage room
                                    columnLabel: row1Column3Label
                                    columnValue: Functions.toStr(row1_column3)
                                }
                            }

                            Row {
                                id: columnsRow2
                                width: parent.width
                                PlanEntryColumn {
                                    width: parent.width / 3 * 1 - Theme.paddingSmall
                                    //: OverviewPage course new
                                    columnLabel: row2Column1Label
                                    columnValue: Functions.toStr(row2_column1)
                                }
                                PlanEntryColumn {
                                    width: parent.width / 3 * 2 - Theme.paddingSmall
                                    //: OverviewPage text
                                    columnLabel: row2Column2Label
                                    columnValue: Functions.toStr(row2_column2)
                                }
                            }

                            Row {
                                id: columnsRow3
                                width: parent.width
                                visible: row3Visible
                                PlanEntryColumn {
                                    width: parent.width / 3 * 1 - Theme.paddingSmall
                                    //: OverviewPage course new
                                    columnLabel: row3Column1Label
                                    columnValue: Functions.toStr(row3_column1)
                                }
                                PlanEntryColumn {
                                    width: parent.width / 3 * 2 - Theme.paddingSmall
                                    //: OverviewPage text
                                    columnLabel: row3Column2Label
                                    columnValue: Functions.toStr(row3_column2)
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

    VerticalScrollDecorator {
    }

    Component.onCompleted: {
        app.planDataChanged.connect(receivePlanDataChanged);
        app.loadingStateChanged.connect(receiveLoadingStateChanged);

        plansViewFlickable.hasCredentials = app.hasCredentials();

        Functions.log("[PlansView.onCompleted] - hasCredentials : " + plansViewFlickable.hasCredentials);

        app.getAuthToken();
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
