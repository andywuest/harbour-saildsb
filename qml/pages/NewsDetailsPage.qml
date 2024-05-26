import QtQuick 2.6
import Sailfish.Silica 1.0

import "../components"

Page {
    id: newsDetailsPage
    property var newsItem

    SilicaFlickable {
        anchors {
            fill: parent
            bottomMargin: Theme.paddingMedium
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            spacing: Theme.paddingSmall

            PageHeader {
                //: NewsDetailsPage incident page header
                title: qsTr("News Details")
            }

            Row {
                id: firstRow
                width: parent.width
                height: Theme.fontSizeSmall + Theme.paddingMedium

                Label {
                    id: titleLabel
                    width: parent.width * 6 / 10
                    text: newsItem.title
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    horizontalAlignment: Text.AlignLeft
                }

                Label {
                    id: dateLabel
                    width: parent.width * 4 / 10
                    text: newsItem.date
                    truncationMode: TruncationMode.Fade
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignRight
                }
            }

            Label {
                id: contentLabel
                text: newsItem.detail
                textFormat: Text.RichText
                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

}
