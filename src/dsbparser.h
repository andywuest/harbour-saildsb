#ifndef DSBPARSER_H
#define DSBPARSER_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class DsbParser {
public:
  DsbParser();

public:
  QJsonObject parseHtmlToJson(const QString &planInHtml,
                              const QMap<QString, QString> schoolLabelMap);
  QList<QString> parseTimetable(const QString &timetable);

protected:
  QList<QString> extractPlanLines(QString planTableData);
  QList<QString> extractTableColumns(QString planTableHeadline);
  QString getNormalizedDateString(const QString &date);

  QString extractTableData(const QString &planData);
  void mapFieldToJsonObject(int index, QMap<QString, QString> specificMapping,
                            QList<QString> headlineList, QJsonObject *entryObj,
                            QStringList splitList);

#ifdef UNIT_TEST
  friend class DsbParserTests; // to test non public methods
#endif
};

#endif // DSBPARSER_H
