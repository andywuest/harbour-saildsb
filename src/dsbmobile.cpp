#include "dsbmobile.h"

DsbMobile::DsbMobile(QObject *parent)
    : QObject(parent), networkAccessManager(new QNetworkAccessManager(this)),
      networkConfigurationManager(new QNetworkConfigurationManager(this)),
      settings("harbour-dsbmobile", "settings") {
  dsbMobileBackend = new DsbMobileBackend(this->networkAccessManager, this);
}

DsbMobileBackend *DsbMobile::getDsbMobileBackend() {
  return this->dsbMobileBackend;
}
