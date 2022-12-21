/*
 * harbour-saildsb - Sailfish OS Version
 * Copyright © 2022 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include "dsbparsertests.h"
#include <QtTest/QtTest>

void DsbParserTests::init() { dsbParser = new DsbParser(); }

/*
void DsbParserTests::testParsePlanToJson() {
    qDebug() << "dir : " << QCoreApplication::applicationFilePath();
    qDebug() << "Timezone for test : " << QTimeZone::systemTimeZone();
    QString testDate = QString("2020-10-14T20:22:24+02:00");
    QTimeZone testTimeZone = QTimeZone("Europe/Berlin");
    QDateTime convertedDateTime =
IngDibaUtils::convertTimestampToLocalTimestamp(testDate, testTimeZone); QString
dateTimeFormatted = convertedDateTime.toString("yyyy-MM-dd") + " " +
convertedDateTime.toString("hh:mm:ss"); QCOMPARE(dateTimeFormatted,
QString("2020-10-14 20:22:24"));
}

void IngDibaBackendTests::testIngDibaBackendProcessSearchResult() {
    // TODO use readFileData

    QString testFile = "ie00b57x3v84.json";
    QFile f("testdata/" + testFile);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        QString msg = "Testfile " + testFile + " not found!";
        QFAIL(msg.toLocal8Bit().data());
    }

    QTextStream in(&f);
    QByteArray data = in.readAll().toUtf8();
    QString parsedResult = ingDibaBackend->processSearchResult(data);
    QJsonDocument jsonDocument = QJsonDocument::fromJson(parsedResult.toUtf8());
    QCOMPARE(jsonDocument.isArray(), true);
    QJsonArray resultArray = jsonDocument.array();
    QCOMPARE(resultArray.size(), 1);
}
*/

void DsbParserTests::testParseTimetable() {
    QByteArray data = readFileData("timetable.json");
    if (data.isEmpty()) {
      QString msg = "Testfile timetable.json not found!";
      QFAIL(msg.toLocal8Bit().data());
    }

    const QList<QString> planUrls = dsbParser->parseTimetable(QString(data));
    QCOMPARE(planUrls.size(), 2);
    QCOMPARE(planUrls.at(0), "https://light.dsbcontrol.de/DSBlightWebsite/Data/2adb15e3-8e4d-4102-ae28-2d5cad09bbfd/943ceb37-345f-409f-b2f1-3d994bf873d6/subst_001.htm?638022895036162543");
    QCOMPARE(planUrls.at(1), "https://light.dsbcontrol.de/DSBlightWebsite/Data/2adb15e3-8e4d-4102-ae28-2d5cad09bbfd/07ca34e1-a14e-4252-95fe-9dc42a087e32/subst_001.htm?638022895036162543");
}

void DsbParserTests::testParsePlanToJson() {
  QByteArray data = readFileData("plan.html");
  if (data.isEmpty()) {
    QString msg = "Testfile plan.html not found!";
    QFAIL(msg.toLocal8Bit().data());
  }

  const QJsonObject jsonPlanObject = dsbParser->parseHtmlToJson(QString(data));
  QCOMPARE(jsonPlanObject["data"].isArray(), true);
  QCOMPARE(jsonPlanObject["date"].isString(), true);

  const QString planDate = jsonPlanObject["date"].toString();
  QCOMPARE(planDate, "25.10.2022 Dienstag, Woche A");
  const QJsonArray planData = jsonPlanObject["data"].toArray();
  QCOMPARE(planData.size(), 3);
  QCOMPARE(planData.at(0).toObject().value("class"), "7a");
  QCOMPARE(planData.at(0).toObject().value("course"), "BK");
  QCOMPARE(planData.at(0).toObject().value("hour"), "2");
  QCOMPARE(planData.at(0).toObject().value("newCourse"), "Geo");
  QCOMPARE(planData.at(0).toObject().value("room"), "123");
  QCOMPARE(planData.at(0).toObject().value("type"), "Verlegung");

  /*
      QString parsedResult = ingDibaNews->processSearchResult(data);
      QJsonDocument jsonDocument =
     QJsonDocument::fromJson(parsedResult.toUtf8());
      QCOMPARE(jsonDocument.isObject(), true);

      QJsonArray resultArray = jsonDocument["newsItems"].toArray();
      QCOMPARE(resultArray.size(), 8);

      QJsonObject newsEntry = resultArray.at(0).toObject();
      QCOMPARE(newsEntry["source"], "DJN.576664");
      QCOMPARE(newsEntry["headline"], "Merkel-Vertraute reisen nach Washington
     zu Gesprächen über Nord Stream 2"); QCOMPARE(newsEntry["dateTime"], "Di.
     Juni 1 01:00:00 2021"); // TODO richtiger conversion fehlt noch
      */

  // TODO QCOMPARE first news data entry
}

QByteArray DsbParserTests::readFileData(const QString &fileName) {
  QFile f("testdata/" + fileName);
  if (!f.open(QFile::ReadOnly | QFile::Text)) {
    QString msg = "Testfile " + fileName + " not found!";
    qDebug() << msg << f.fileName() << QFileInfo(f).absoluteFilePath();
    return QByteArray();
  }

  QTextStream in(&f);
  return in.readAll().toUtf8();
}
