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


QVariantMap TokenHelper::getTokensForChoice(QString const& value)
{
    QVariantMap keyValues;
    keyValues["value_text"] = value;

    return keyValues;
}


QVariantMap TokenHelper::getTokensForIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description)
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

    return keyValues;
}


QVariantMap TokenHelper::getTokensForQuestion(QString const& standardBody, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& beforeBody, QString const& afterBody, int difficulty)
{
    QVariantMap keyValues;
    keyValues["standard_body"] = standardBody;
    keyValues["bool_standard_body"] = boolStandardBody;
    keyValues["prompt_standard_body"] = promptStandardBody;
    keyValues["ordered_body"] = orderedBody;
    keyValues["count_body"] = countBody;
    keyValues["bool_count_body"] = boolCountBody;
    keyValues["prompt_count_body"] = promptCountBody;
    keyValues["before_body"] = beforeBody;
    keyValues["after_body"] = afterBody;
    keyValues["difficulty"] = difficulty;

    return keyValues;
}


} /* namespace admin */
