#include "dsbparser.h"

#include <QDateTime>
#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRegularExpression>
#include <QUrl>

DsbParser::DsbParser() {}

QList<QString> DsbParser::parseTimetable(QString timetable) {
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
        QString tableNoClasses =
            planTableData
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

QJsonObject DsbParser::parseHtmlToJson(QString planInHtml) {
  QString planInHtmlCopy = QString(planInHtml);
  QRegularExpression dateRegExp(
      "<div class=\"mon_title\">([\\.\\,\\w\\s]+)</div>");

  QString matchedDate("-");
  QRegularExpressionMatch match = dateRegExp.match(planInHtml);
  if (match.hasMatch()) {
    qDebug() << "date match : " << match.capturedStart(1);
    qDebug() << "date match : " << match.capturedEnd(1);
    matchedDate = planInHtml.mid(match.capturedStart(1),
                                 match.capturedEnd(1) - match.capturedStart(1));
    qDebug() << "date match : " << matchedDate;
  }

  qDebug() << "1" << QTime::currentTime().toString("hh:mm:ss.zzz");

  QString tableDataOnly =
      planInHtml
          .replace(QRegExp(".*<table class=\"mon_list\" >"), "") //
          .replace(QRegExp("</table>.*"), "");

  qDebug() << "2" << QTime::currentTime().toString("hh:mm:ss.zzz");

  QStringList lines = extractPlanLines(tableDataOnly);

  qDebug() << "3" << QTime::currentTime().toString("hh:mm:ss.zzz");

  QJsonArray resultArray;
  for (int i = 0; i < lines.size(); ++i) {
    qDebug() << lines.at(i);
    QString line = lines.at(i);
    if (line.indexOf("<th") != -1 || line.isEmpty()) {
      continue;
    }

    QString tokenLine = line.replace("<td >", "<td>")  //
                            .replace("</td><td>", "|") //
                            .replace("</td></tr>", "") //
                            .replace("<td>", "")       //
                            .replace("\r", "")         //
                            .replace("\n", "");

    QStringList splitList = tokenLine.split("|");

    if (splitList.length() == 6) {
      QJsonObject entry;
      entry.insert("theClass", splitList.at(0));
      entry.insert("hour", splitList.at(1));
      entry.insert("course", splitList.at(2));
      entry.insert("type", splitList.at(3));
      entry.insert("newCourse", splitList.at(4));
      entry.insert("room", splitList.at(5));

      qDebug() << " adding entry ";

      resultArray.push_back(entry);

    } else {
      qDebug() << "unexpected length of splitList !";
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

  // qDebug() << " Table : \n" << tableNoClasses;

  QJsonObject planObject;
  planObject.insert("date", matchedDate);
  planObject.insert("data", resultArray);
  planObject.insert("title", schoolData);
  return planObject;
}
