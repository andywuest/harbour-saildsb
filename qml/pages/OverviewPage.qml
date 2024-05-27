import QtQuick 2.0
import QtQml.Models 2.2
import Sailfish.Silica 1.0

import "../components"
import "../components/thirdparty"

import "../js/functions.js" as Functions

Page {
    id: overviewPage

    property int activeTabId: 0
    property int numberOfTabs: 2

    function openTab(tabId) {
        activeTabId = tabId
        Functions.log("[OverviewPage] opening tab :" + tabId);

        switch (tabId) {
        case 0:
            plansButtonPortrait.isActive = true
            newsButtonPortrait.isActive = false
            break
        case 1:
            plansButtonPortrait.isActive = false
            newsButtonPortrait.isActive = true
            break
        default:
            Functions.log("[OverviewPage] Some strange navigation happened!")
        }
    }

    function getNavigationRowSize() {
        return Theme.iconSizeMedium + Theme.fontSizeMedium + Theme.paddingMedium
    }

    function handlePlansClicked() {
        if (overviewPage.activeTabId === 0) {
            plansView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(0)
            openTab(0)
        }
    }

    function handleNewsClicked() {
        if (overviewPage.activeTabId === 1) {
            newsView.scrollToTop()
        } else {
            viewsSlideshow.opacity = 0
            slideshowVisibleTimer.goToTab(1)
            openTab(1)
        }
    }

    function repopulateTabs() {
        Functions.log("[OverviewPage] updating the tabs model views");
        viewsModel.clear();
        viewsModel.append(plansColumn);
        viewsModel.append(newsColumn);
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            console.log("overview page active");
        }
    }

    // TODO test properly -> not yet used in case of an error
    AppNotification {
        id: planUpdateNotification
    }

    Item {
        id: plansColumn
        width: viewsSlideshow.width
        height: viewsSlideshow.height

        PlansView {
            id: plansView
            width: parent.width
            height: parent.height
        }
    }

    Item {
        id: newsColumn
        width: viewsSlideshow.width
        height: viewsSlideshow.height

        NewsView {
            id: newsView
            width: parent.width
            height: parent.height
        }
    }

    SilicaFlickable {
        id: overviewContainer
        anchors.fill: parent
        visible: true
        contentHeight: parent.height
        contentWidth: parent.width

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
                    var settingsPage = pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                    // settingsPage.reloadOverviewSecurities.connect(reloadOverviewSecurities)
                }
            }
            MenuItem {
                //: OverviewPage settings menu item
                text: qsTr("Refresh")
                onClicked: app.getAuthToken();
            }
        }

        Column {
            id: overviewColumn
            visible: true
            width: parent.width
            height: parent.height

            Behavior on opacity {
                NumberAnimation {
                }
            }

            Row {
                id: overviewRow
                width: parent.width
                height: parent.height - getNavigationRowSize() // - overviewColumnHeader.height
                spacing: Theme.paddingSmall

                ObjectModel {
                    id: viewsModel
                }

                Timer {
                    id: slideshowVisibleTimer
                    property int tabId: 0
                    interval: 50
                    repeat: false
                    onTriggered: {
                        viewsSlideshow.positionViewAtIndex(
                                    tabId, PathView.SnapPosition)
                        viewsSlideshow.opacity = 1
                    }
                    function goToTab(newTabId) {
                        tabId = newTabId
                        start()
                    }
                }

                SlideshowView {
                    id: viewsSlideshow
                    width: parent.width
                    height: parent.height
                    itemWidth: width
                    clip: true
                    model: viewsModel
                    onCurrentIndexChanged: {
                        openTab(currentIndex)
                    }
                    Behavior on opacity {
                        NumberAnimation {
                        }
                    }
                    onOpacityChanged: {
                        if (opacity === 0) {
                            slideshowVisibleTimer.start()
                        }
                    }
                }
            }

            Column {
                id: navigationRow
                width: parent.width
                height: overviewPage.isPortrait ? getNavigationRowSize() : 0
                visible: true // overviewPage.isPortrait
                Column {
                    id: navigationRowSeparatorColumn
                    width: parent.width
                    height: Theme.paddingMedium
                    Separator {
                        id: navigationRowSeparator
                        width: parent.width
                        color: Theme.primaryColor
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }

                Row {
                    y: Theme.paddingSmall
                    width: parent.width
                    Item {
                        id: plansButtonColumn
                        width: parent.width / numberOfTabs
                        height: parent.height - Theme.paddingMedium
                        NavigationRowButton {
                            id: plansButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("Plans")
                            iconSource: "image://theme/icon-m-home"

                            function runOnClick() {
                                handlePlansClicked()
                            }
                        }
                    }
                    Item {
                        id: newsButtonColumn
                        width: parent.width / numberOfTabs
                        height: parent.height - navigationRowSeparator.height
                        NavigationRowButton {
                            id: newsButtonPortrait
                            anchors.top: parent.top
                            buttonText: qsTr("News")
                            iconSource: "image://theme/icon-m-note"

                            function runOnClick() {
                                handleNewsClicked()
                            }
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            repopulateTabs();
            openTab(0)
        }

    }

}
