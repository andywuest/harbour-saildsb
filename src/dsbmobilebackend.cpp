#include "dsbmobilebackend.h"
#include "constants.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTextCodec>

#include "dsbparser.h"

QMap<QString, QString> DsbMobileBackend::MAP_ROW_COLUMNS_GSG_SILLENBUCH{
    // general - headline
    {"Stunde", "hour"},
    {"Klasse(n)", "theClass"},
    // row 1
    {"(Fach)", "row1_column1"}, //
    {"Art", "row1_column2"},    //
    {"Raum", "row1_column3"},   //
    // row 2
    {"Fach", "row2_column1"}, //
    {"Text", "row2_column2"}, //
};

QMap<QString, QString> DsbMobileBackend::MAP_ROW_COLUMNS_RS_HUERTH{
    // general - headline
    {"Stunde", "hour"},
    {"Klasse(n)", "theClass"},
    // row 1
    {"(Fach)", "row1_column1"},
    {"Art", "row1_column2"},
    {"Raum", "row1_column3"},
    // row 2
    {"(Lehrer)", "row2_column1"},
    {"Text", "row2_column2"},
    // row 3
    {"Vertreter", "row3_column1"},
};

DsbMobileBackend::DsbMobileBackend(QNetworkAccessManager *networkAccessManager,
                                   QObject *parent)
    : QObject(parent) {
  qDebug() << "Initializing DsbMobileBackend...";
  this->networkAccessManager = networkAccessManager;
}

DsbMobileBackend::~DsbMobileBackend() {
  qDebug() << "Shutting down DsbMobileBackend...";
}

QNetworkRequest DsbMobileBackend::prepareNetworkRequest(const QUrl url,
                                                        bool contentTypeJson) {
  QNetworkRequest request(url);
  if (contentTypeJson) {
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
    request.setRawHeader("Accept", MIME_TYPE_JSON);
  } else {
    request.setRawHeader("Accept", MIME_TYPE_HTML);
  }
  request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);

  qDebug() << "fetching : " << url;

  return request;
}

void DsbMobileBackend::getAuthToken(const QString &user,
                                    const QString &password) {
  executeGetAuthToken(QUrl(QString(URL_LOGIN).arg(user, password)));
}

void DsbMobileBackend::getPlans(const QString &authToken, const int schoolId) {
  this->schoolId = schoolId;
  executeGetPlans(QUrl(QString(URL_TIMETABLES).arg(authToken)));
}

void DsbMobileBackend::executeGetAuthToken(const QUrl &url) {
  qDebug() << "DsbMobileBackend::executeGetAuthToken " << url;

  QNetworkRequest request = prepareNetworkRequest(url, true);
  QNetworkReply *reply = networkAccessManager->get(request);

  connectErrorSlot(reply);
  connect(reply, SIGNAL(finished()), this, SLOT(handleGetAuthTokenFinished()));
}

void DsbMobileBackend::executeGetPlans(const QUrl &url) {
  qDebug() << "DsbMobileBackend::executeGetPlans " << url;

  QNetworkRequest request = prepareNetworkRequest(url, true);
  QNetworkReply *reply = networkAccessManager->get(request);

  connectErrorSlot(reply);
  connect(reply, SIGNAL(finished()), this, SLOT(handleGetPlansFinished()));
}

void DsbMobileBackend::handleGetAuthTokenFinished() {
  qDebug() << "DsbMobileBackend::handleGetAuthTokenFinished";
  QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
  reply->deleteLater();
  if (reply->error() != QNetworkReply::NoError) {
    return;
  }

  processGetAuthTokenResult(reply);
}

void DsbMobileBackend::handleGetPlansFinished() {
  qDebug() << "DsbMobileBackend::handleGetPlansFinished";
  QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
  reply->deleteLater();
  if (reply->error() != QNetworkReply::NoError) {
    return;
  }

  processGetPlansResult(reply);
}

void DsbMobileBackend::processGetAuthTokenResult(QNetworkReply *reply) {
  qDebug() << "DsbMobileBackend::processGetAuthTokenResult";
  QByteArray responseData = reply->readAll();
  QString result = QString(responseData).replace("\"", "");

  qDebug() << result;
  emit authTokenAvailable(result);
}

void DsbMobileBackend::processGetPlansResult(QNetworkReply *reply) {
  qDebug() << "DsbMobileBackend::processGetPlansResult";

  QByteArray responseData = reply->readAll();
  QString result = QString(responseData);

  qDebug() << result;

  // TODO instantiate in constructor
  DsbParser *dsbParser = new DsbParser();
  QList<QString> planUrls = dsbParser->parseTimetable(result);

  this->numberOfPlans = planUrls.size();
  timetableResults.clear();

  foreach (const QString &planUrl, planUrls) {
    qDebug() << "looking up url " << planUrl;

    QNetworkRequest request = prepareNetworkRequest(QUrl(planUrl), false);
    QNetworkReply *reply = networkAccessManager->get(request);

    connectErrorSlot(reply);
    connect(reply, SIGNAL(finished()), this,
            SLOT(handleGetTimetableFinished()));
  }

  //  emit authTokenAvailable(result);
  // emit plansAvailable("plans available");
}

bool compareByDate(const QJsonObject &obj1, const QJsonObject &obj2) {
  QDate date1 = QDate::fromString(obj1["date"].toString(), DEFAULT_DATE_FORMAT);
  QDate date2 = QDate::fromString(obj2["date"].toString(), DEFAULT_DATE_FORMAT);

  qDebug() << "DsbMobileBackend::compareByDate" << date1 << ", " << date2;

  return date1 < date2;
}

void DsbMobileBackend::handleGetTimetableFinished() {
  qDebug() << "DsbMobileBackend::handleGetTimetableFinished";
  QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
  reply->deleteLater();
  if (reply->error() != QNetworkReply::NoError) {
    return;
  }

  QByteArray responseData = reply->readAll();
  //  QString result = QString(responseData);

  QTextCodec *windows1250Codec = QTextCodec::codecForName("Windows-1252");
  QString result = windows1250Codec->toUnicode(responseData);

  // TODO instantiate in constructor
  DsbParser *dsbParser = new DsbParser();
  QJsonObject jsonObject = dsbParser->parseHtmlToJson(
      result, getRowMappingForSchool(this->schoolId));
  timetableResults.append(jsonObject);

  if (timetableResults.size() == this->numberOfPlans) {

    std::sort(timetableResults.begin(), timetableResults.end(), compareByDate);

    QJsonDocument resultDocument;
    QJsonArray resultArray;

    foreach (const QJsonObject &timetableResultObject, timetableResults) {
      resultArray.push_back(timetableResultObject);
    }

    resultDocument.setArray(resultArray);
    QString dataToString(resultDocument.toJson());

    emit plansAvailable(dataToString);
  }
}

QMap<QString, QString>
DsbMobileBackend::getRowMappingForSchool(const int schoolId) {
  switch (schoolId) {
  // same constants as in constants.js
  case 0:
    return MAP_ROW_COLUMNS_GSG_SILLENBUCH;
  case 1:
    return MAP_ROW_COLUMNS_RS_HUERTH;
  case 2:
  default:
    qDebug() << "School with id " << schoolId << "not defined !";
    return QMap<QString, QString>();
  }
}

void DsbMobileBackend::connectErrorSlot(QNetworkReply *reply) {
  // connect the error and also emit the error signal via a lambda expression
  connect(reply,
          static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(
              &QNetworkReply::error),
          [=](QNetworkReply::NetworkError error) {
            QByteArray result = reply->readAll();

            // TODO test reply->deleteLater();
            qWarning() << "DsbMobileBackend::handleRequestError:"
                       << static_cast<int>(error) << reply->errorString()
                       << result;

            const QJsonDocument jsonDocument = QJsonDocument::fromJson(result);
            // use general error string - if we did not get json response error
            QString errorString = reply->errorString();
            if (jsonDocument.isObject()) {
              errorString = jsonDocument.object()["Message"].toString();
            }
            emit requestError(
                "Return code: " + QString::number(static_cast<int>(error)) +
                " - " + errorString);

            // TODO -> move to separate method
            //            QJsonDocument jsonDocument =
            //            QJsonDocument::fromJson(result); if
            //            (jsonDocument.isObject()) {
            //              QJsonObject responseObject = jsonDocument.object();

            //              // responses do not always look the same
            //              if
            //              (!responseObject["error_description"].toString().isEmpty())
            //              {
            //                QString errorDescription =
            //                    responseObject["error_description"].toString();
            //                qWarning() << "error description : " <<
            //                errorDescription; emit
            //                requestError(errorDescription);
            //              } else if
            //              (!responseObject["messages"].toArray().isEmpty()) {
            //                QJsonArray messageArray =
            //                responseObject["messages"].toArray(); QString
            //                errorDescription =
            //                    messageArray.at(0).toObject()["message"].toString();
            //                qWarning() << "error description : " <<
            //                errorDescription; emit
            //                requestError(errorDescription);
            //              }
            //            } else {
            //              emit requestError(
            //                  "Return code: " +
            //                  QString::number(static_cast<int>(error)) + " - "
            //                  + reply->errorString());
            //            }
          });
}
