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

  Q_SIGNAL void authTokenAvailable(const QString &authToken);
  Q_SIGNAL void requestError(const QString &errorMessage);

protected:
  QNetworkAccessManager *networkAccessManager;

  QNetworkRequest prepareNetworkRequest(const QUrl url);

  void connectErrorSlot(QNetworkReply *reply);

private:
  void executeGetAuthToken(const QUrl &url);
  void processGetAuthTokenResult(QNetworkReply *reply);

private slots:
  void handleGetAuthTokenFinished();
};

#endif // DSBMOBILEBACKEND_H
