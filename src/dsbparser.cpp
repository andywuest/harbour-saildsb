#include "dsbparser.h"

#include <QDateTime>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QUrl>

#include "constants.h"

DsbParser::DsbParser() {}

QList<QString> DsbParser::parseTimetable(const QString &timetable) {
  const QJsonArray rootArray =
      QJsonDocument::fromJson(timetable.toUtf8()).array();

  QList<QString> planUrls;

  foreach (const QJsonValue &timetableObject, rootArray) {
    const QJsonObject timetableEntry = timetableObject.toObject();
    const QJsonArray childArray = timetableEntry["Childs"].toArray();
    foreach (const QJsonValue &childObject, childArray) {
      const QJsonObject childEntry = childObject.toObject();
      const QString htmlPlanUrl = childEntry["Detail"].toString();
      if (!htmlPlanUrl.isEmpty()) {
        planUrls.append(htmlPlanUrl);
      }
    }
  }

  return planUrls;
}

QList<QString> DsbParser::extractPlanLines(QString planTableData) {
  if (planTableData.contains("Keine Vertretung")) {
    return QList<QString>();
  } else {
    QString tableNoClasses = planTableData
                                 .replace("list", "")                      //
                                 .replace("center", "")                    //
                                 .replace(" odd", "")                      //
                                 .replace(" even", "")                     //
                                 .replace("background-color: #FFFFFF", "") //
                                 .replace(" class=''", "")                 //
                                 .replace(" align=\"\"", "")               //
                                 .replace(" class=\"\"", "")               //
                                 .replace(" style=\"\"", "")               //
                                 .replace("\r", "")                        //
                                 .replace("\n", "");

    return tableNoClasses.split("<tr>");
  }
}

QList<QString> DsbParser::extractTableColumns(QString planTableHeadline) {
  if (!planTableHeadline.startsWith("<th")) {
    return QList<QString>();
  } else {
    QString headline = planTableHeadline
                           .replace(QRegExp("^<th>"), "") //
                           .replace(" width='16'", "")    //
                           .replace("</th></tr>", "");    //
    qDebug() << "headline vor spit : " << headline;
    return headline.split("</th><th>");
  }
}

QString DsbParser::getNormalizedDateString(const QString &dateString) {
  QDate date = QDate::fromString(dateString, "d.M.yyyy");
  if (date.isValid()) {
    return date.toString(DEFAULT_DATE_FORMAT);
  }
  return dateString;
}

QString DsbParser::extractTableData(const QString &planData) {
  long startPos = planData.indexOf("<table class=\"mon_list\" >") +
                  QString("<table class=\"mon_list\" >").length();
  long endPos = planData.indexOf("</table>", startPos);

  qDebug() << "start pos : " << startPos << " - end pos : " << endPos;

  QStringRef subString(&planData, startPos, endPos - startPos);
  return subString.toString().remove("\n");
}

QJsonObject
DsbParser::parseHtmlToJson(const QString &planInHtml,
                           const QMap<QString, QString> schoolLabelMap) {
  qDebug() << "0" << QTime::currentTime().toString("hh:mm:ss.zzz");

  QString planInHtmlCopy = QString(planInHtml.toUtf8());
  QRegularExpression dateRegExp(
      "<div class=\"mon_title\">([\\.\\,\\w\\s]+)</div>");
  QRegularExpression dateOnlyRegExp(
      "<div class=\"mon_title\">(\\d{1,2}\\.\\d{1,2}\\.\\d{4})");

  QString matchedDate("-");
  QRegularExpressionMatch match = dateRegExp.match(planInHtml);
  if (match.hasMatch()) {
    qDebug() << "date match : " << match.capturedStart(1);
    qDebug() << "date match : " << match.capturedEnd(1);
    matchedDate = planInHtml.mid(match.capturedStart(1),
                                 match.capturedEnd(1) - match.capturedStart(1));
    qDebug() << "date match : " << matchedDate;
  }

  QString matchedDateOnly("-");
  QRegularExpressionMatch dateOnlyMatch = dateOnlyRegExp.match(planInHtml);
  if (dateOnlyMatch.hasMatch()) {
    matchedDateOnly = planInHtml.mid(dateOnlyMatch.capturedStart(1),
                                     dateOnlyMatch.capturedEnd(1) -
                                         dateOnlyMatch.capturedStart(1));
    matchedDateOnly = getNormalizedDateString(matchedDateOnly);
    qDebug() << "dateOnly match : " << matchedDateOnly;
  } else {
    qDebug() << "dateOnly no match : " << matchedDateOnly;
  }

  QString tableDataOnly = extractTableData(planInHtml);
  QStringList lines = extractPlanLines(tableDataOnly);

  QJsonArray resultArray;
  QJsonObject labels;

  QList<QString> headlineList;
  for (int i = 0; i < lines.size(); ++i) {
    // qDebug() << lines.at(i);

    QString line = lines.at(i);
    if (line.indexOf("<th") != -1) {
      headlineList = extractTableColumns(line);
      continue;
    } else if (line.isEmpty()) {
      continue;
    }

    const QString tokenLine = line.replace("<td >", "<td>")  //
                                  .replace("</td><td>", "|") //
                                  .replace("</td></tr>", "") //
                                  .replace("<td>", "")       //
                                  .replace("&nbsp;", "")     //
                                  .replace("\r", "")         //
                                  .replace("\n", "");

    const QStringList splitList = tokenLine.split("|");
    QJsonObject entry;

    for (int i = 0; i < splitList.length(); i++) {
      mapFieldToJsonObject(i, schoolLabelMap, headlineList, &entry, splitList);
    }

    const QList<QString> keys = schoolLabelMap.keys();
    for (const auto &key : keys) {
      labels.insert(schoolLabelMap[key], key);
    }

    if (entry.size() > 0) {
      resultArray.push_back(entry);
    } else {
      qDebug() << "unexpected length of splitList -> length : "
               << splitList.length();
    }

    qDebug() << tokenLine;
  }

  QString schoolData = planInHtmlCopy
                           .replace(QRegExp("</table>.*"), "")  //
                           .replace(QRegExp(".*bottom\">"), "") //
                           .replace(QRegExp("<span.*"), "")     //
                           .replace(QRegExp("<p>"), "")         //
                           .replace(QRegExp("^\\s*"), "")       //
                           .replace(QRegExp("\\s*$"), "");

  qDebug() << "school data : " << schoolData;
  qDebug() << "days : " << resultArray.size();

  QJsonObject planObject;
  planObject.insert("dateString", matchedDate);
  planObject.insert("date", matchedDateOnly);
  planObject.insert("data", resultArray);
  planObject.insert("labels", labels);
  planObject.insert("title", schoolData);
  return planObject;
}

void DsbParser::mapFieldToJsonObject(int index,
                                     QMap<QString, QString> specificMapping,
                                     QList<QString> headlineList,
                                     QJsonObject *entryObj,
                                     QStringList splitList) {
  QJsonObject *entry = dynamic_cast<QJsonObject *>(entryObj);
  if (index < headlineList.length()) {
    QString headlineText = headlineList.at(index);
    QString jsonKey = specificMapping.value(headlineText, "??");
    entry->insert(jsonKey, splitList.at(index));
  }
}
