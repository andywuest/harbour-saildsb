#include "dsbparser.h"

#include <QDateTime>
#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QRegularExpression>
#include <QUrl>

DsbParser::DsbParser() {}

QList<QString> DsbParser::parseTimetable(QString timetable) {
    const QJsonArray rootArray = QJsonDocument::fromJson(timetable.toUtf8()).array();

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

QJsonObject DsbParser::parseHtmlToJson(QString planInHtml) {
  QJsonArray resultArray;

  // qDebug() << planInHtml;

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

  QString tableDataOnly =
      planInHtml
          .replace(QRegExp(".*<table class=\"mon_list\" >"), "") //
          .replace(QRegExp("</table>.*"), "");

  QString tableNoClasses =
      tableDataOnly
          .replace(QRegExp("list"), "")                      //
          .replace(QRegExp("center"), "")                    //
          .replace(QRegExp(" odd"), "")                      //
          .replace(QRegExp(" even"), "")                     //
          .replace(QRegExp("background-color: #FFFFFF"), "") //
          .replace(QRegExp(" class=''"), "")                 //
          .replace(QRegExp(" align=\"\""), "")               //
          .replace(QRegExp(" class=\"\""), "")               //
          .replace(QRegExp(" style=\"\""), "");

  QStringList lines = tableNoClasses.split("<tr>");

  for (int i = 0; i < lines.size(); ++i) {
    qDebug() << lines.at(i);
    QString line = lines.at(i);
    if (line.indexOf("<th") != -1) {
      continue;
    }

    QString tokenLine = line.replace(QRegExp("<td >"), "<td>")  //
                            .replace(QRegExp("</td><td>"), "|") //
                            .replace(QRegExp("</td></tr>"), "") //
                            .replace(QRegExp("<td>"), "")       //
                            .replace(QRegExp("\n"), "");

    QStringList splitList = tokenLine.split("|");

    if (splitList.length() == 6) {
      QJsonObject entry;
      entry.insert("class", splitList.at(0));
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

  // qDebug() << " Table : \n" << tableNoClasses;

  QJsonObject planObject;
  planObject.insert("date", matchedDate);
  planObject.insert("data", resultArray);
  return planObject;
}
