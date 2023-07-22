/*
 * harbour-saildsb - Sailfish OS Version
 * Copyright © 2023 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/functions.js" as Functions

CoverBackground {
    id: coverPage

    property var planData
    property bool loading : false;

    function receivePlanDataChanged(result, error, date) {
        Functions.log("[CoverPage] - data has changed, result : " + result
                      + ", error " + error + ", date : " + date)

        if (result) {
            coverPage.planData = result;
            addPlanDataToModel();
        } else if (error) {
            // TODO display no data
        }

        coverActionRefresh.enabled = true;

        loading = false;
    }

    function addPlanDataToModel() {
        Functions.log("[CoverPage] - addPlanDataToModel called.");
        coverModel.clear();

        var filterTokens = Functions.getFilterTokens(sailDsbSettings.filter)
        if (!coverPage.planData) {
            return;
        }

        for (var i = 0; i < coverPage.planData.length; i++) {
            var dayData = coverPage.planData[i];
            var allFiltered = true;
            if (dayData.data.length > 0) {
                var standInCount = 0;
                for (var j = 0; j < dayData.data.length; j++) {
                    var planDay = dayData.data[j];
                    if (!Functions.isFilterTokenMatch(planDay.theClass, filterTokens)) {
                        // ignore
                    } else {
                        standInCount++;
                        allFiltered = false;
                    }
                }
                coverModel.append(createCoveModelEntry(dayData.date, standInCount));
            } else {
                coverModel.append(createCoveModelEntry(dayData.date, "0"));
            }
        }
    }

    function createCoveModelEntry(date, standInCount) {
        var entry = {};
        entry.date = date;
        entry.numberOfStandins = standInCount;
        return entry;
    }

    onVisibleChanged: {
        Functions.log("[CoverPage] - visible changed :");
        // read plan to model whenever visible changes -
        // e.g. filter was changed and we minimize the app
        addPlanDataToModel();
    }

    Column {
        id: loadingColumn
        width: parent.width - 2 * Theme.horizontalPageMargin
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingMedium
        visible: coverPage.loading
        Behavior on opacity {
            NumberAnimation {
            }
        }
        opacity: coverPage.loading ? 1 : 0
        InfoLabel {
            id: loadingLabel
            text: qsTr("Loading...")
            font.pixelSize: Theme.fontSizeMedium
        }
    }

    CoverActionList {
        id: coverActionRefresh

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                Functions.log("reload clicked")
                loading = true;
                coverActionRefresh.enabled = false
                app.getAuthToken();
            }
        }
    }

    SilicaListView {
        id: coverListView

        visible: !coverPage.loading
        Behavior on opacity { NumberAnimation {} }
        opacity: coverPage.loading ? 0 : 1

        anchors.fill: parent

        model: ListModel {
            id: coverModel
        }

        header: Text {
            id: labelTitle
            width: parent.width
            topPadding: Theme.paddingLarge
            bottomPadding: Theme.paddingMedium
            text: qsTr("Stand-ins")
            color: Theme.primaryColor
            font.bold: true
            font.pixelSize: Theme.fontSizeSmall
            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignHCenter
        }

        delegate: ListItem {

            contentHeight: planDayColumn.height + Theme.paddingMedium

            Column {
                id: planDayColumn
                x: Theme.paddingLarge
                width: parent.width - 2 * Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    width: parent.width
                    height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                    Label {
                        id: planDateLabel
                        width: parent.width * 6 / 10
                        height: parent.height
                        text: qsTr("%1 :").arg(date) // TODO format date properly
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        truncationMode: TruncationMode.Fade
                    }

                    Text {
                        id: planDateStandinText
                        width: parent.width * 4 / 10
                        height: parent.height
                        text: numberOfStandins
                        horizontalAlignment: Text.AlignRight
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        font.bold: false
                    }
                }
            }
        }

        Component.onCompleted: {
            app.planDataChanged.connect(receivePlanDataChanged)
        }
    }

    OpacityRampEffect {
        sourceItem: coverListView
        direction: OpacityRamp.TopToBottom
        offset: 0.6
        slope: 3.75
    }

}
