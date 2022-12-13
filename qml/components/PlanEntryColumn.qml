import QtQuick 2.6
import Sailfish.Silica 1.0

Column {
    property alias columnLabel: labelText.text
    property alias columnValue: valueText.text

    Text {
        id: labelText
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
    }
    Text {
        id: valueText
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryHighlightColor
    }
}
