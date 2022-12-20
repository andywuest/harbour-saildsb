#include "dsbmobilebackend.h"
#include "constants.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

#include "dsbparser.h"

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
  return request;
}

void DsbMobileBackend::getAuthToken(const QString &user,
                                    const QString &password) {
  executeGetAuthToken(QUrl(QString(URL_LOGIN).arg(user, password)));
}

void DsbMobileBackend::getPlans(const QString &authToken) {
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
  qDebug() << "CommbankAccountService::processGetAuthTokenResult";
  QByteArray responseData = reply->readAll();
  QString result = QString(responseData).replace("\"", "");

  qDebug() << result;
  emit authTokenAvailable(result);
}

void DsbMobileBackend::processGetPlansResult(QNetworkReply *reply) {
  qDebug() << "CommbankAccountService::processGetPlansResult";

  QByteArray responseData = reply->readAll();
  QString result = QString(responseData);

  const QJsonArray rootArray = QJsonDocument::fromJson(responseData).array();

  QList<QString> planUrls;

  foreach (const QJsonValue &timetableObject, rootArray) {
    QJsonObject timetableEntry = timetableObject.toObject();
    const QJsonArray childArray = timetableEntry["Childs"].toArray();
    foreach (const QJsonValue &childObject, childArray) {
      QJsonObject childEntry = childObject.toObject();
      QString htmlPlanUrl = childEntry["Detail"].toString();
      if (!htmlPlanUrl.isEmpty()) {
        planUrls.append(htmlPlanUrl);
      }
    }
  }

  qDebug() << result;

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
  emit plansAvailable("plans available");
}

void DsbMobileBackend::handleGetTimetableFinished() {
  qDebug() << "DsbMobileBackend::handleGetTimetableFinished";
  QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
  reply->deleteLater();
  if (reply->error() != QNetworkReply::NoError) {
    return;
  }

  QByteArray responseData = reply->readAll();
  QString result = QString(responseData);

  // TODO instantiate in constructor
  DsbParser *dsbParser = new DsbParser();
  QJsonObject jsonObject = dsbParser->parseHtmlToJson(result);
  timetableResults.append(jsonObject);

  if (timetableResults.size() == this->numberOfPlans) {
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
