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

CoverBackground {
    id: coverPage
    property bool loading : false;

    function populateModel() {
        coverModel.clear();

        var entry = {};
        entry.date = "12.12.2023";
        entry.numberOfStandins = 10;

        var entry2 = {};
        entry2.date = "13.12.2023";
        entry2.numberOfStandins = 9;

        coverModel.append (entry);
        coverModel.append (entry2);
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
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-pause"
//        }
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

            // height: resultLabelTitle.height + resultLabelContent.height + Theme.paddingSmall
            contentHeight: planDayColumn.height + Theme.paddingMedium

            // TODO custom - hier noch pruefen, was an margins noch machbar, sinnvoll ist
            Column {
                id: planDayColumn
                x: Theme.paddingLarge
                width: parent.width - 2 * Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter

                Row {
//                    id: firstRow
                    width: parent.width
                    height: Theme.fontSizeExtraSmall + Theme.paddingSmall

                    Label {
                        id: planDateLabel
                        width: parent.width * 6 / 10
                        height: parent.height
                        text: qsTr("%1 :").arg(date)
                        // truncationMode: TruncationMode.Elide // TODO check for very long texts
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

//                Row {
//                    id: thirdRow
//                    width: parent.width
//                    height: Theme.fontSizeTiny + Theme.paddingSmall

//                    Text {
//                        id: stockQuoteChange
//                        width: parent.width / 2
//                        height: parent.height
//                        text: Functions.renderPrice(price, currencySymbol)
//                        color: Theme.highlightColor
//                        font.pixelSize: Theme.fontSizeTiny
//                        font.bold: true
//                        horizontalAlignment: Text.AlignLeft
//                    }

//                    Text {
//                        id: changePercentageText
//                        width: parent.width / 2
//                        height: parent.height
//                        text: Functions.renderChange(price, changeRelative, '%')
//                        color: determineChangeColor(changeRelative)
//                        font.pixelSize: Theme.fontSizeTiny
//                        horizontalAlignment: Text.AlignRight
//                    }
//                }
            }
        }

        Component.onCompleted: {
//            var dataBackend = getSecurityDataBackend(watchlistSettings.dataBackend);
//            dataBackend.quoteResultAvailable.connect(quoteResultHandler)
//            dataBackend.requestError.connect(errorResultHandler)
//            app.securityAdded.connect(securityAdded);
//            reloadAllStocks()
            populateModel();
        }
    }

    OpacityRampEffect {
        sourceItem: coverListView
        direction: OpacityRamp.TopToBottom
        offset: 0.6
        slope: 3.75
    }

}
