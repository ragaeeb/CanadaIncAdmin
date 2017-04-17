#include "TokenHelper.h"

namespace admin {

QVariantMap TokenHelper::getTokensForAnswer(qint64 questionId, qint64 choiceId, bool correct)
{
    QVariantMap keyValues;
    keyValues["question_id"] = questionId;
    keyValues["choice_id"] = choiceId;
    keyValues["correct"] = correct;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForSuite(qint64 author, qint64 translator, qint64 explainer, QString const& title, QString const& displayName, QString const& description, QString const& reference, bool isBook)
{
    QVariantMap keyValues;
    keyValues["author"] = author;
    keyValues["translator"] = translator;
    keyValues["explainer"] = explainer;
    keyValues["title"] = title;
    keyValues["displayName"] = displayName;
    keyValues["description"] = description;
    keyValues["reference"] = reference;
    keyValues["is_book"] = isBook;

    return keyValues;
}



QVariantMap TokenHelper::getTokensForLocation(QString const& city, qreal latitude, qreal longitude)
{
    QVariantMap keyValues;
    keyValues["city"] = city;
    keyValues["latitude"] = latitude;
    keyValues["longitude"] = longitude;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForWebsite(qint64 individualId, QString const& address)
{
    QVariantMap keyValues;
    keyValues["individual"] = individualId;
    keyValues["uri"] = address;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForSuitePage(qint64 suiteId, QString const& body, QString const& heading, QString const& reference)
{
    QVariantMap keyValues;
    keyValues["suite_id"] = suiteId;
    keyValues["body"] = body;
    keyValues["heading"] = heading;
    keyValues["reference"] = reference;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForQuote(qint64 author, qint64 translator, QString const& body, QString const& reference, qint64 suiteId, QString const& uri)
{
    QVariantMap keyValues;
    keyValues["author"] = author;
    keyValues["body"] = body;
    keyValues["reference"] = reference;
    keyValues["suite_id"] = suiteId;
    keyValues["translator"] = translator;
    keyValues["uri"] = uri;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForChoice(QString const& value)
{
    QVariantMap keyValues;
    keyValues["value_text"] = value;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description, int madhab)
{
    QVariantMap keyValues;
    keyValues["birth"] = birth;
    keyValues["current_location"] = currentLocation.toLongLong();
    keyValues["death"] = death;
    keyValues["notes"] = description;
    keyValues["displayName"] = displayName;
    keyValues["female"] = female;
    keyValues["hidden"] = hidden;
    keyValues["is_companion"] = level;
    keyValues["kunya"] = kunya;
    keyValues["location"] = location.toLongLong();
    keyValues["name"] = name;
    keyValues["prefix"] = prefix;
    keyValues["madhab"] = madhab;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForQuestion(QString const& standardBody, QString const& standardNegation, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& beforeBody, QString const& afterBody, int difficulty, qint64 sourceId)
{
    QVariantMap keyValues;
    keyValues["standard_body"] = standardBody;
    keyValues["standard_negation_body"] = standardNegation;
    keyValues["bool_standard_body"] = boolStandardBody;
    keyValues["prompt_standard_body"] = promptStandardBody;
    keyValues["ordered_body"] = orderedBody;
    keyValues["count_body"] = countBody;
    keyValues["bool_count_body"] = boolCountBody;
    keyValues["prompt_count_body"] = promptCountBody;
    keyValues["before_body"] = beforeBody;
    keyValues["after_body"] = afterBody;
    keyValues["difficulty"] = difficulty;
    keyValues["source_id"] = sourceId;

    return keyValues;
}


} /* namespace admin */
