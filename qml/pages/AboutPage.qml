import QtQuick 2.6
import Sailfish.Silica 1.0

import "../components/thirdparty"

Page {
    id: page

    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: aboutPageFlickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width:parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                //: AboutPage - Header
                title: qsTr("About")
            }

            Image {
                id: logo
                source: "/usr/share/icons/hicolor/172x172/apps/harbour-saildsb.png"
                smooth: true
                height: width
                width: parent.width / 2
                sourceSize.width: 512
                sourceSize.height: 512
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.7
            }

            Label {
                width: parent.width
                x : Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.secondaryHighlightColor

                //: AboutPage - Name
                text: qsTr("SailDSB")
            }

            Label {
                width: parent.width
                x : Theme.horizontalPageMargin
                text: applicationVersion
            }

            Item {
                height: Theme.paddingMedium
                width: 1
            }

            AboutDescription {
                //: AboutPage text - about text
                description: qsTr("This is app is a native Sailfish OS client for the DSBMobile. SailDSB is open source and licensed under the GPL v3.")
            }

            /*
            SectionHeader {
                //: AboutPage - Translations
                text: qsTr("Translations")
            }

            AboutDescription {
                //: AboutPage - translations
                description: ""
            }
            */

            SectionHeader{
                id: sectionHeaderSources
                //: AboutPage - sources
                text: qsTr("Sources")
            }

            AboutIconLabel {
                iconSource: "icons/github.svg"
                label: "https://github.com/andywuest/harbour-saildsb"
                targetUrl: "https://github.com/andywuest/harbour-saildsb"
            }

            SectionHeader{
                //: AboutPage - Donations
                text: qsTr("Donations")
            }

            AboutDescription {
                //: AboutPage - donations info
                description: qsTr("If you like my work why not buy me a beer?")
            }

            AboutIconLabel {
                iconSource: "icons/paypal.svg"
                label: qsTr("Donate with PayPal")
                targetUrl: "https://www.paypal.com/paypalme/andywuest"
            }

            Item {
                width: 1
                height: Theme.paddingSmall
            }
        }
    }

    VerticalScrollDecorator {
        flickable: aboutPageFlickable
    }
}
