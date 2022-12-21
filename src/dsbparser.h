#ifndef DSBPARSER_H
#define DSBPARSER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class DsbParser {
public:
  DsbParser();

public:
  QJsonObject parseHtmlToJson(QString planInHtml);
  QList<QString> parseTimetable(QString timetable);
};

#endif // DSBPARSER_H
