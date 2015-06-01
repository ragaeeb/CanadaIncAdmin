APP_NAME = CanadaIncAdmin

CONFIG += qt warn_on cascades10
INCLUDEPATH += ../../canadainc/src/
INCLUDEPATH += ../../quazip/src/
LIBS += -lbbdata -lbbsystem -lbbcascadespickers -lbb -lbbplatform -lbbdevice -lbbdata
QT += network

include(config.pri)
