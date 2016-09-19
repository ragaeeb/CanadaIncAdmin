#ifndef OFFLOADER_H_
#define OFFLOADER_H_

#include <QObject>
#include <QVariant>

namespace admin {

class Offloader : public QObject
{
    Q_OBJECT

    QSet<QString> m_prefixes;
    QSet<QString> m_kunyas;

public:
    Offloader();
    virtual ~Offloader();

    Q_INVOKABLE static QVariantList decorateWebsites(QVariantList input);
    Q_INVOKABLE QVariantMap parseName(QString const& n);
    Q_INVOKABLE static QString toTitleCase(QString const& input);
    Q_INVOKABLE static int diffSecs(QString const& input);
    Q_INVOKABLE static QString extractHost(QString const& uri);
};

} /* namespace quran */

#endif /* OFFLOADER_H_ */
