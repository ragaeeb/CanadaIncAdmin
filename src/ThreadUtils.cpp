#include "precompiled.h"

#include "ThreadUtils.h"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "JlCompress.h"
#include "Logger.h"

namespace admin {

QPair<QByteArray, QString> ThreadUtils::compressDatabase(QString const& dbPath)
{
    LOGGER(dbPath);

    QStringList toCompress;
    toCompress << QString("%1/%2.db").arg( QDir::homePath() ).arg(dbPath);

    JlCompress::compressFiles(ILM_DB_ARCHIVE_DESTINATION, toCompress, ILM_ARCHIVE_PASSWORD);

    QFile f(ILM_DB_ARCHIVE_DESTINATION);
    f.open(QIODevice::ReadOnly);

    QByteArray qba = f.readAll();
    f.close();

    QString md5 = canadainc::IOUtils::getMd5(qba);

    LOGGER("CompressionComplete" << md5);

    return qMakePair<QByteArray, QString>(qba, md5);
}


} /* namespace admin */
