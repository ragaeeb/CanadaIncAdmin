#ifndef TOKENHELPER_H_
#define TOKENHELPER_H_

#include <QVariant>

namespace admin {

struct TokenHelper
{
    static QVariantMap getTokensForAnswer(qint64 questionId, qint64 choiceId, bool correct);
    static QVariantMap getTokensForChoice(QString const& value);
    static QVariantMap getTokensForIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description);
    static QVariantMap getTokensForQuestion(QString const& standardBody, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& beforeBody, QString const& afterBody, int difficulty);
};

} /* namespace admin */

#endif /* TOKENHELPER_H_ */
