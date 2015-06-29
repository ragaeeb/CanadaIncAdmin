#ifndef THREADUTILS_H_
#define THREADUTILS_H_

#include <QByteArray>
#include <QPair>
#include <QString>

namespace admin {

struct ThreadUtils
{
    static QPair<QByteArray, QString> compressDatabase(QString const& tafsirPath);

    static bool seedDatabase(QString const& source, QStringList const& languages);
};

} /* namespace quran */

#endif /* THREADUTILS_H_ */
