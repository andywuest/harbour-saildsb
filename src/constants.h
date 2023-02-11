#ifndef CONSTANTS_H
#define CONSTANTS_H

const char MIME_TYPE_JSON[] = "application/json";
const char MIME_TYPE_HTML[] = "text/html";

const char USER_AGENT[] = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:73.0) "
                          "Gecko/20100101 Firefox/73.0";

const char DEFAULT_DATE_FORMAT[] = "dd.MM.yyyy";

const char URL_LOGIN[] =
    "https://mobileapi.dsbcontrol.de/"
    "authid?user=%1&password=%2&bundleid=de.heinekingmedia.dsbmobile&"
    "appversion=35&osversion=22&pushid"; // user, password

const char URL_TIMETABLES[] =
    "https://mobileapi.dsbcontrol.de/dsbtimetables?authid=%1"; // authToken

#endif // CONSTANTS_H
