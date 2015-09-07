#ifndef OFFLOADER_H_
#define OFFLOADER_H_

#include <QObject>
#include <QVariant>

namespace admin {

class Offloader : public QObject
{
    Q_OBJECT

public:
    Offloader();
    virtual ~Offloader();

    Q_INVOKABLE QVariantList decorateWebsites(QVariantList input);
    Q_INVOKABLE QVariantList fillType(QVariantList input, int queryId);
    Q_INVOKABLE QString toTitleCase(QString const& input);
};

} /* namespace quran */

#endif /* OFFLOADER_H_ */
