#include "precompiled.h"

#include "ThreadUtils.h"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "JlCompress.h"
#include "Logger.h"

namespace admin {

QPair<QByteArray, QString> ThreadUtils::compressDatabase(QString const& tafsirPath)
{
    LOGGER("compressing database" << tafsirPath);

    QStringList toCompress;
    toCompress << QString("%1/%2.db").arg( QDir::homePath() ).arg(tafsirPath);

    JlCompress::compressFiles(TAFSIR_ZIP_DESTINATION, toCompress, TAFSIR_ARCHIVE_PASSWORD);

    QFile f(TAFSIR_ZIP_DESTINATION);
    f.open(QIODevice::ReadOnly);

    QByteArray qba = f.readAll();
    f.close();

    QString md5 = canadainc::IOUtils::getMd5(qba);

    LOGGER("CompressionComplete" << md5);

    return qMakePair<QByteArray, QString>(qba, md5);
}


bool ThreadUtils::seedDatabase(QString const& source, QStringList const& languages)
{
    bool success = false;

    foreach (QString const& language, languages)
    {
        QString dest = QString("%1/%2.db").arg( QDir::homePath() ).arg(language);

        if ( QFile::exists(dest) )
        {
            LOGGER("RemoveExisting" << dest);
            LOGGER( QFile::remove(dest) );
        }

        if ( !QFile::copy( QString("%1/%2.db").arg( QDir::homePath() ).arg(source), dest ) ) {
            return false;
        }
    }

    return true;
}

} /* namespace admin */
