#include "dsbmobilebackend.h"
#include "constants.h"

DsbMobileBackend::DsbMobileBackend(QNetworkAccessManager *networkAccessManager,
                                   QObject *parent)
    : QObject(parent) {
  qDebug() << "Initializing DsbMobileBackend...";
  this->networkAccessManager = networkAccessManager;
}

DsbMobileBackend::~DsbMobileBackend() {
  qDebug() << "Shutting down DsbMobileBackend...";
}

QNetworkRequest DsbMobileBackend::prepareNetworkRequest(const QUrl url) {
  QNetworkRequest request(url);
  request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);
  request.setRawHeader("Accept", MIME_TYPE_JSON);
  request.setHeader(QNetworkRequest::UserAgentHeader, USER_AGENT);
  return request;
}

void DsbMobileBackend::getAuthToken(const QString &user,
                                    const QString &password) {
  executeGetAuthToken(QUrl(QString(URL_LOGIN).arg(user, password)));
}

void DsbMobileBackend::executeGetAuthToken(const QUrl &url) {
  qDebug() << "DsbMobileBackend::executeGetAuthToken " << url;

  QNetworkRequest request = prepareNetworkRequest(url);
  QNetworkReply *reply = networkAccessManager->get(request);

  connectErrorSlot(reply);
  connect(reply, SIGNAL(finished()), this, SLOT(handleGetAuthTokenFinished()));
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

void DsbMobileBackend::processGetAuthTokenResult(QNetworkReply *reply) {
  qDebug() << "CommbankAccountService::processGetAuthTokenResult";
  QByteArray responseData = reply->readAll();
  QString result = QString(responseData).replace("\"", "");

  qDebug() << result;
  emit authTokenAvailable(result);
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
