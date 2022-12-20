#ifndef DSBMOBILEBACKEND_H
#define DSBMOBILEBACKEND_H

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class DsbMobileBackend : public QObject {
  Q_OBJECT
public:
  explicit DsbMobileBackend(QNetworkAccessManager *networkAccessManager,
                            QObject *parent = nullptr);
  ~DsbMobileBackend();

  Q_INVOKABLE void getAuthToken(const QString &user, const QString &password);
  Q_INVOKABLE void getPlans(const QString &authToken);

  Q_SIGNAL void authTokenAvailable(const QString &authToken);
  Q_SIGNAL void plansAvailable(const QString &result);
  Q_SIGNAL void requestError(const QString &errorMessage);

protected:
  QNetworkAccessManager *networkAccessManager;

  QNetworkRequest prepareNetworkRequest(const QUrl url, bool contentTypeJson);

  void connectErrorSlot(QNetworkReply *reply);

private:
  int numberOfPlans = 0;
  QList<QJsonObject> timetableResults;

  void executeGetAuthToken(const QUrl &url);
  void processGetAuthTokenResult(QNetworkReply *reply);
  void executeGetPlans(const QUrl &url);
  void processGetPlansResult(QNetworkReply *reply);

private slots:
  void handleGetAuthTokenFinished();
  void handleGetPlansFinished();
  void handleGetTimetableFinished();
};

#endif // DSBMOBILEBACKEND_H
