import QtQuick 2.6
import Sailfish.Silica 1.0

// QTBUG-34418
import "."

import "../js/constants.js" as Constants
import "../js/functions.js" as Functions

import "../components"
import "../components/thirdparty"

SilicaFlickable {
    id: newsViewFlickable

    property bool loading : false
    property var newsData
    property bool hasCredentials : false

    function receiveNewsDataChanged(result, error, date) {
        Functions.log("[NewsView] - data has changed, result : " + result
                      + ", error " + error + ", date : " + date)

        if (result) {
            newsViewFlickable.newsData = result;
            addNewsDataToModel();
        } else if (error) {
            newsEntriesHeader.description = "";
            planUpdateNotification.show(error);
        }

        loading = false;
    }

    function receiveLoadingStateChanged(isLoading) {
        Functions.log("[NewsView] - isLoading changed, result : " + isLoading);
        newsViewFlickable.loading = isLoading;
    }

    function addNewsDataToModel() {
        Functions.log("[NewsView] - addNewsDataToModel called.");
        Functions.log("[NewsView] - schoolId : " + sailDsbSettings.schoolId);
        newsEntriesModel.clear();

        for (var i = 0; i < newsViewFlickable.newsData.length; i++) {
            var newsData = newsViewFlickable.newsData[i];
            newsEntriesModel.append(newsData);
        }
    }

    function isNoNewsLabelVisible() {
        if (newsViewFlickable.hasCredentials) {
            if (newsData && newsData && newsData.length > 0) {
                return false;
            }
            return true;
        }
        return false;
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingMedium

        PageHeader {
            id: newsEntriesHeader
            title: qsTr("News")
        }

        Label {
            id: noCredentialsLabel
            horizontalAlignment: Text.AlignHCenter
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            visible: !newsViewFlickable.hasCredentials

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: qsTr("Please provide valid credentials via the Settings to see the news.")
        }

        Label {
            id: noNewsLabel
            horizontalAlignment: Text.AlignHCenter
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            visible: isNoNewsLabelVisible()

            wrapMode: Text.Wrap
            textFormat: Text.RichText
            text: qsTr("No news available.")
        }

        SilicaListView {
            id: newsEntriesListView

            height: newsViewFlickable.height - newsEntriesHeader.height - Theme.paddingMedium
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            visible: (!noCredentialsLabel.visible && !noNewsLabel.visible)

            clip: true

            model: ListModel {
                id: newsEntriesModel
            }

            delegate: ListItem {
                id: delegate

                contentHeight: newsItem.height + (2 * Theme.paddingMedium)
                contentWidth: parent.width

                Item {
                    id: newsItem
                    width: parent.width
                    height: newsItemColumn.height + newsSeparator.height
                    y: Theme.paddingMedium

                    Column {
                        id: newsItemColumn
                        width: parent.width - (2 * Theme.horizontalPageMargin)
                        height: firstRow.height + secondRow.height + Theme.paddingMedium
                        spacing: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Row {
                            id: firstRow
                            width: parent.width
                            height: Theme.fontSizeSmall + Theme.paddingMedium

                            Label {
                                id: titleLabel
                                width: parent.width * 6 / 10
                                text: title
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: true
                                horizontalAlignment: Text.AlignLeft
                            }

                            Label {
                                id: dateLabel
                                width: parent.width * 4 / 10
                                text: date
                                truncationMode: TruncationMode.Fade
                                color: Theme.highlightColor
                                font.pixelSize: Theme.fontSizeSmall
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        Row {
                            id: secondRow
                            width: parent.width
                            height: (Theme.fontSizeSmall + Theme.paddingMedium) * 3 - Theme.paddingMedium

                            Text {
                                id: detailText
                                text: detail
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.primaryColor
                                width: parent.width
                                height: Theme.fontSizeSmall
                                maximumLineCount: 3

                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    Separator {
                        id: newsSeparator
                        anchors.top: newsItemColumn.bottom
                        anchors.topMargin: Theme.paddingMedium

                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }

                onClicked: {
                    Functions.log("[NewsView.onClicked] - index number clicked : " + index);
                    var selectedItem = newsEntriesListView.model.get(index)
                    pageStack.push(Qt.resolvedUrl("../pages/NewsDetailsPage.qml"), {
                                       newsItem: selectedItem
                                   });
                }
            }
        }
    }

    VerticalScrollDecorator {
    }

    Component.onCompleted: {
        app.newsDataChanged.connect(receiveNewsDataChanged);
        app.loadingStateChanged.connect(receiveLoadingStateChanged);

        newsViewFlickable.hasCredentials = app.hasCredentials();

        Functions.log("[NewsView.onCompleted] - hasCredentials : " + newsViewFlickable.hasCredentials);
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
