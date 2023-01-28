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

void DsbParserTests::testParseTimetable() {
  QByteArray data = readFileData("timetable.json");
  QVERIFY2(data.length() > 0, "Testfile not found!");

  const QList<QString> planUrls = dsbParser->parseTimetable(QString(data));
  QCOMPARE(planUrls.size(), 2);
  QCOMPARE(
      planUrls.at(0),
      "https://light.dsbcontrol.de/DSBlightWebsite/Data/"
      "2adb15e3-8e4d-4102-ae28-2d5cad09bbfd/"
      "943ceb37-345f-409f-b2f1-3d994bf873d6/subst_001.htm?638022895036162543");
  QCOMPARE(
      planUrls.at(1),
      "https://light.dsbcontrol.de/DSBlightWebsite/Data/"
      "2adb15e3-8e4d-4102-ae28-2d5cad09bbfd/"
      "07ca34e1-a14e-4252-95fe-9dc42a087e32/subst_001.htm?638022895036162543");
}

void DsbParserTests::testParsePlanToJson() {
  QByteArray data = readFileData("plan.html");
  QVERIFY2(data.length() > 0, "Testfile not found!");

  const QJsonObject jsonPlanObject = dsbParser->parseHtmlToJson(QString(data));
  QCOMPARE(jsonPlanObject["data"].isArray(), true);
  QCOMPARE(jsonPlanObject["date"].isString(), true);
  QCOMPARE(jsonPlanObject["title"].isString(), true);

  const QString planDate = jsonPlanObject["date"].toString();
  QCOMPARE(planDate, "25.10.2022 Dienstag, Woche A");

  const QString title = jsonPlanObject["title"].toString();
  QCOMPARE(title, "GESCHW.-SCHOLL-GYM STUTTGART");

  const QJsonArray planData = jsonPlanObject["data"].toArray();
  QCOMPARE(planData.size(), 3);
  QCOMPARE(planData.at(0).toObject().value("theClass"), "7a");
  QCOMPARE(planData.at(0).toObject().value("course"), "BK");
  QCOMPARE(planData.at(0).toObject().value("hour"), "2");
  QCOMPARE(planData.at(0).toObject().value("newCourse"), "Geo");
  QCOMPARE(planData.at(0).toObject().value("room"), "123");
  QCOMPARE(planData.at(0).toObject().value("type"), "Verlegung");
}

void DsbParserTests::testExtractTableData() {
  QByteArray data = readFileData("plan.html");
  QVERIFY2(data.length() > 0, "Testfile not found!");

  const QString result = dsbParser->extractTableData(QString(data));
  QCOMPARE(result.startsWith("<tr class='list'><"), true);
  QCOMPARE(result.endsWith(">105</td></tr>"), true);
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
