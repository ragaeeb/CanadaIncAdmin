#ifndef TOKENHELPER_H_
#define TOKENHELPER_H_

#include <QVariant>

namespace admin {

struct TokenHelper
{
    static QVariantMap getTokensForQuote(qint64 author, QString const& body, QString const& reference, qint64 suiteId, QString const& uri);
    static QVariantMap getTokensForSuite(qint64 author, qint64 translator, qint64 explainer, QString const& title, QString const& description, QString const& reference);
    static QVariantMap getTokensForSuitePage(qint64 suiteId, QString const& body, QString const& heading, QString const& reference);
    static QVariantMap getTokensForAnswer(qint64 questionId, qint64 choiceId, bool correct);
    static QVariantMap getTokensForWebsite(qint64 individualId, QString const& address);
    static QVariantMap getTokensForLocation(QString const& city, qreal latitude, qreal longitude);
    static QVariantMap getTokensForChoice(QString const& value);
    static QVariantMap getTokensForIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description);
    static QVariantMap getTokensForQuestion(QString const& standardBody, QString const& standardNegation, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& beforeBody, QString const& afterBody, int difficulty);
    static QVariantMap getTokensForBooks(qint64 author, QString const& title);
};

} /* namespace admin */

#endif /* TOKENHELPER_H_ */
