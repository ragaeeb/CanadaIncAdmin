#ifndef COMMONCONSTANTS_H_
#define COMMONCONSTANTS_H_

#include <QUrl>

#define KEY_APP_DB_VERSION "dbAppVersion"
#define KEY_TAFSIR_VERSION(a) a+"TafsirVersion"
#define TAFSIR_ARCHIVE_PASSWORD "55XXo@Z_11QHh@"

namespace quran {

struct CommonConstants
{
    static QUrl generateHostUrl(QString const& path=QString());
};

}

#endif /* COMMONCONSTANTS_H_ */
