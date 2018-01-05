#-------------------------------------------------
#
# Project created by QtCreator 2016-05-17T16:13:58
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = winn
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    mydialog.cpp

HEADERS  += mainwindow.h \
    mydialog.h \
    functions.h

FORMS    += mainwindow.ui \
    mydialog.ui

RESOURCES += \
    myres.qrc
