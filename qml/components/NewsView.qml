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

        SilicaListView {
            id: newsEntriesListView

            height: newsViewFlickable.height - newsEntriesHeader.height - Theme.paddingMedium
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !noCredentialsLabel.visible

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
                        height: headlineLabel.height + dateTimeLabel.height + Theme.paddingMedium
                        spacing: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Label {
                            id: headlineLabel
                            text: date
                            truncationMode: TruncationMode.Fade
                            font.pixelSize: Theme.fontSizeSmall
                            width: parent.width
                            height: Theme.fontSizeSmall
                        }
                        Label {
                            id: dateTimeLabel
                            text: title
                            font.pixelSize: Theme.fontSizeTiny
                            width: parent.width
                            height: Theme.fontSizeTiny
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
//                    pageStack.push(Qt.resolvedUrl("../pages/NewsPage.qml"), {
//                                       newsItem: selectedItem
//                                   });
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
