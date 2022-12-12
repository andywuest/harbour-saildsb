import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import "pages"
import "cover"

ApplicationWindow
{
    id: app

    // Global Settings Storage
    ConfigurationGroup {
        id: sailDsbSettings
        path: "/apps/harbour-saildsb/settings"

        property string username
        property string password
    }

    Component {
        id: overviewPage
        OverviewPage {
        }
    }

    Component {
        id: coverPage
        CoverPage {
        }
    }

    initialPage: overviewPage
    cover: coverPage
    allowedOrientations: defaultAllowedOrientations

}
