#ifndef DSBPARSER_H
#define DSBPARSER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class DsbParser {
public:
  DsbParser();

public:
  QJsonDocument parseHtmlToJson(QString planInHtml);
};

#endif // DSBPARSER_H