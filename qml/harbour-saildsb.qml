import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

import "pages"
import "cover"

import "js/functions.js" as Functions
import "js/constants.js" as Constants

ApplicationWindow
{
    id: app
    property string authToken: "";

    signal planDataChanged(var planData, string error, date lastUpdate)

    function connectSlots() {
        Functions.log("[ApplicationWindow] connect - slots");
        dsbMobileBackend.authTokenAvailable.connect(authTokenResultHandler);
        dsbMobileBackend.plansAvailable.connect(plansResultHandler);
        dsbMobileBackend.requestError.connect(errorResultHandler);
    }

    function disconnectSlots() {
        Functions.log("[ApplicationWindow] disconnect - slots");
        dsbMobileBackend.authTokenAvailable.disconnect(authTokenResultHandler);
        dsbMobileBackend.plansAvailable.disconnect(plansResultHandler);
        dsbMobileBackend.requestError.disconnect(errorResultHandler);
    }

    function plansResultHandler(result) {
        Functions.log("[ApplicationWindow] plan data received - " + result);
        if ("no" === result) {
            planDataChanged(null, qsTr("No plan data found."), new Date());
        } else {
            planDataChanged(JSON.parse(result), "", new Date());
        }
    }

    function errorResultHandler(result) {
        Functions.log("[ApplicationWindow] - result error : " + result);
        planDataChanged(null, result, new Date());
    }

    function hasCredentials() {
        return Functions.hasCredentials(sailDsbSettings.userName, sailDsbSettings.password);
    }

    // TODO handle auth token errors properly -> show messag if not credentials are given
    function getAuthToken() {
        disconnectSlots();
        connectSlots();
        if (hasCredentials()) {
            dsbMobileBackend.getAuthToken(sailDsbSettings.userName, sailDsbSettings.password);
         } else {
            planDataChanged({}, qsTr("No credentials configured."), new Date());
        }
    }

    function authTokenResultHandler(result) {
        Functions.log("[OverviewPage] auth token received - " + result);
        app.authToken = result;
        dsbMobileBackend.getPlans(authToken, sailDsbSettings.schoolId);
    }

    // Global Settings Storage
    ConfigurationGroup {
        id: sailDsbSettings
        path: "/apps/harbour-saildsb/settings"

        property int schoolId: Constants.GSG_SILLENBUCH
        property string userName
        property string password
        property string filter // comma separated filter values, e.g. "5c, 8a"
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
