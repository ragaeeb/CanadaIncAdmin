#ifndef COMMONCONSTANTS_H_
#define COMMONCONSTANTS_H_

#include <QUrl>

#define LIKE_CLAUSE(field) QString("(%1 LIKE '%' || ? || '%')").arg(field)
#define NAME_SEARCH_FLAGGED(var, startsWith) QString("%1.name LIKE %2 ? || '%' OR %1.displayName LIKE %2 ? || '%' OR %1.kunya LIKE %2 ? || '%'").arg(var).arg(startsWith ? "" : "'%' ||")
#define NAME_SEARCH(var) NAME_SEARCH_FLAGGED(var, false)
#define ILM_DB_FILE(lang) QString("ilm_%1").arg(lang)
#define REMOVE_ELEMENT(table,type) LOGGER(id); m_sql->executeDelete(caller, table, type, id)
#define SET_KEY_VALUE_ID if (id) keyValues["id"] = id;
#define SET_AND_RETURN SET_KEY_VALUE_ID; return keyValues
#define ILM_ARCHIVE_PASSWORD "_@zxX1@z_J9W5h@"
#define ILM_DB_ARCHIVE_DESTINATION QString("%1/plugins.zip").arg( QDir::tempPath() )

namespace admin {

struct CommonConstants
{
};

}

#endif /* COMMONCONSTANTS_H_ */
