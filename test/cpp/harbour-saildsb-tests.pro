QT += qml testlib network sql
QT -= gui

CONFIG += c++11 qt

SOURCES += testmain.cpp \
    dsbparsertests.cpp

HEADERS += \
    dsbparsertests.h

INCLUDEPATH += ../../
include(../../harbour-saildsb.pri)

TARGET = DsbParserTests

DISTFILES += \
    testdata/plan.html \
    testdata/news.json \
    testdata/timetable.json

DEFINES += UNIT_TEST

