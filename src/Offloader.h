#ifndef OFFLOADER_H_
#define OFFLOADER_H_

#include <QObject>
#include <QVariant>

namespace bb {
    namespace cascades {
        class ArrayDataModel;
    }
}

namespace admin {

class Offloader : public QObject
{
    Q_OBJECT

    QSet<QString> m_prefixes;
    QSet<QString> m_kunyas;

private slots:
    void onResultsDecorated();
    void onGroupedDecorated();

public:
    Offloader();
    virtual ~Offloader();

    Q_INVOKABLE void decorateGroupedResults(QVariantList const& input, QObject* caller);
    Q_INVOKABLE void decorateSearchResults(QVariantList const& input, bb::cascades::ArrayDataModel* adm, QVariantList const& queries);
    Q_INVOKABLE static QVariantList decorateWebsites(QVariantList input);
    Q_INVOKABLE static QVariantList fillType(QVariantList input, int queryId);
    Q_INVOKABLE QVariantMap parseName(QString const& n);
    Q_INVOKABLE static QString toTitleCase(QString const& input);
};

} /* namespace quran */

#endif /* OFFLOADER_H_ */
