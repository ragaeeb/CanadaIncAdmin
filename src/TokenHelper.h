#ifndef TOKENHELPER_H_
#define TOKENHELPER_H_

#include <QVariant>

namespace admin {

struct TokenHelper
{
    static QVariantMap getTokensForIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description);
};

} /* namespace admin */

#endif /* TOKENHELPER_H_ */
