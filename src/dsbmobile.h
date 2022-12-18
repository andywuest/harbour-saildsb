#ifndef DSBMOBILE_H
#define DSBMOBILE_H

#include <QNetworkAccessManager>
#include <QNetworkConfigurationManager>
#include <QObject>
#include <QSettings>

#include "dsbmobilebackend.h"

class DsbMobile : public QObject {
  Q_OBJECT
public:
  explicit DsbMobile(QObject *parent = nullptr);
  ~DsbMobile() = default;

  DsbMobileBackend *getDsbMobileBackend();

private:
  QNetworkAccessManager *const networkAccessManager;
  QNetworkConfigurationManager *const networkConfigurationManager;

  DsbMobileBackend *dsbMobileBackend;

  QSettings settings;
};

#endif // DSBMOBILE_H
