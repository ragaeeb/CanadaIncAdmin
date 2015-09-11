#ifndef COMMONCONSTANTS_H_
#define COMMONCONSTANTS_H_

#include <QUrl>

#define KEY_APP_DB_VERSION "dbAppVersion"
#define KEY_TAFSIR_VERSION(a) a+"TafsirVersion"
#define QURAN_TAFSIR_FILE(lang) QString("quran_tafsir_%1").arg(lang)
#define SET_KEY_VALUE_ID if (id) keyValues["id"] = id;
#define TAFSIR_ARCHIVE_PASSWORD "55XXo@Z_11QHh@"
#define TAFSIR_ZIP_DESTINATION QString("%1/plugins.zip").arg( QDir::tempPath() )

namespace admin {

struct CommonConstants
{
    static QUrl generateGeocodingUrl();
    static QUrl generateHostUrl(QString const& path=QString());
};

}

#endif /* COMMONCONSTANTS_H_ */
