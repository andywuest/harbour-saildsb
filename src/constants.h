#ifndef CONSTANTS_H
#define CONSTANTS_H

const char MIME_TYPE_JSON[] = "application/json";

const char USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) "
                          "Gecko/20100101 Firefox/73.0";

const char URL_LOGIN[] =
    "https://mobileapi.dsbcontrol.de/"
    "authid?user=%1&password=%2&bundleid=de.heinekingmedia.dsbmobile&"
    "appversion=35&osversion=22&pushid"; // user, password

#endif // CONSTANTS_H
