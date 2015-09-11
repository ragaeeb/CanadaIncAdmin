#ifndef COMMONCONSTANTS_H_
#define COMMONCONSTANTS_H_

#include <QUrl>

#define KEY_APP_DB_VERSION "dbAppVersion"
#define KEY_TAFSIR_VERSION(a) a+"TafsirVersion"
#define NAME_SEARCH_FLAGGED(var, startsWith) QString("%1.name LIKE %2 ? || '%' OR %1.displayName LIKE %2 ? || '%' OR %1.kunya LIKE %2 ? || '%'").arg(var).arg(startsWith ? "" : "'%' ||")
#define NAME_SEARCH(var) NAME_SEARCH_FLAGGED(var, false)
#define QURAN_TAFSIR_FILE(lang) QString("quran_tafsir_%1").arg(lang)
#define REMOVE_ELEMENT(table,type) LOGGER(id); m_sql->executeDelete(caller, table, type, id)
#define SET_KEY_VALUE_ID if (id) keyValues["id"] = id;
#define SET_AND_RETURN SET_KEY_VALUE_ID; return keyValues
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
