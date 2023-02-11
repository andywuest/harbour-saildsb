#ifndef DSBPARSER_H
#define DSBPARSER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class DsbParser {
public:
  DsbParser();

public:
  QJsonObject parseHtmlToJson(const QString &planInHtml);
  QList<QString> parseTimetable(const QString &timetable);

protected:
  QList<QString> extractPlanLines(QString planTableData);
  QString getNormalizedDateString(const QString &date);

  QString extractTableData(const QString &planData);

#ifdef UNIT_TEST
  friend class DsbParserTests; // to test non public methods
#endif
};

#endif // DSBPARSER_H
