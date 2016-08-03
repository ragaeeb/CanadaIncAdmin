#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QByteArray>
#include <QPair>
#include <QString>

namespace admin {

struct UploadData
{
    QByteArray data;
    QString md5;
    bool notifyClients;
    QString cookie;

    UploadData() : notifyClients(false) {}
};

struct ThreadUtils
{
    static UploadData compressDatabase(QString const& tafsirPath, bool notifyClients);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
