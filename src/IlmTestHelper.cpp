#include "precompiled.h"

#include "IlmTestHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "TokenHelper.h"

#define FIELD_SORT_ORDER "sort_order"
#define FIELD_SOURCE_ID "source_id"
#define FIELD_VALUE_TEXT "value_text"

namespace ilmtest {

using namespace admin;
using namespace canadainc;

IlmTestHelper::IlmTestHelper(DatabaseHelper* sql) : m_sql(sql)
{
}

void IlmTestHelper::lazyInit()
{
}


QVariantMap IlmTestHelper::addAnswer(qint64 questionId, qint64 choiceId, bool correct)
{
    LOGGER(questionId << choiceId << correct);

    QVariantMap keyValues = TokenHelper::getTokensForAnswer(questionId, choiceId, correct);
    qint64 id = m_sql->executeInsert("answers", keyValues);

    SET_AND_RETURN;
}


QVariantMap IlmTestHelper::editAnswer(QObject* caller, qint64 id, bool correct)
{
    QVariantMap keyValues;
    keyValues["correct"] = correct;

    m_sql->executeUpdate(caller, "answers", keyValues, QueryId::EditAnswer, id);

    SET_AND_RETURN;
}


QVariantMap IlmTestHelper::addChoice(QString const& value)
{
    LOGGER(value);

    QVariantMap keyValues = TokenHelper::getTokensForChoice(value);
    qint64 id = m_sql->executeInsert("choices", keyValues);

    SET_AND_RETURN;
}


QVariantMap IlmTestHelper::addQuestion(qint64 suitePageId, QString const& standardBody, QString const& standardNegation, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& afterBody, QString const& beforeBody, int difficulty, qint64 sourceId)
{
    LOGGER( suitePageId << standardBody.size() << standardNegation.size() << boolStandardBody.size() << promptStandardBody.size() << orderedBody.size() << countBody.size() << boolCountBody.size() << promptCountBody.size() << beforeBody.size() << afterBody.size() << difficulty << sourceId );

    QVariantMap keyValues = TokenHelper::getTokensForQuestion(standardBody, standardNegation, boolStandardBody, promptStandardBody, orderedBody, countBody, boolCountBody, promptCountBody, beforeBody, afterBody, difficulty, sourceId);
    keyValues["suite_page_id"] = suitePageId;
    qint64 id = m_sql->executeInsert("questions", keyValues);

    SET_AND_RETURN;
}


QVariantMap IlmTestHelper::editChoice(QObject* caller, qint64 id, QString const& value)
{
    LOGGER(id << value);

    QVariantMap keyValues = TokenHelper::getTokensForChoice(value);
    m_sql->executeUpdate(caller, "choices", keyValues, QueryId::EditChoice, id);

    SET_AND_RETURN;
}


QVariantMap IlmTestHelper::editQuestion(QObject* caller, qint64 id, QString const& standardBody, QString const& standardNegation, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& afterBody, QString const& beforeBody, int difficulty, qint64 sourceId)
{
    LOGGER( id << standardBody.size() << standardNegation.size() << boolStandardBody.size() << promptStandardBody.size() << orderedBody.size() << countBody.size() << boolCountBody.size() << promptCountBody.size() << beforeBody.size() << afterBody.size() << difficulty << sourceId );

    QVariantMap keyValues = TokenHelper::getTokensForQuestion(standardBody, standardNegation, boolStandardBody, promptStandardBody, orderedBody, countBody, boolCountBody, promptCountBody, beforeBody, afterBody, difficulty, sourceId);
    m_sql->executeUpdate(caller, "questions", keyValues, QueryId::EditQuestion, id);

    SET_AND_RETURN;
}


void IlmTestHelper::fetchAllChoices(QObject* caller, QString const& choice)
{
    LOGGER(choice);
    QString q = "SELECT * FROM choices WHERE id > 0";
    QVariantList args;

    if ( !choice.isEmpty() ) {
        q += QString(" AND %1 LIKE '%' || ? || '%'").arg(FIELD_VALUE_TEXT);
        args << choice;
    }

    q += QString(" ORDER BY %1").arg(FIELD_VALUE_TEXT);

    m_sql->executeQuery(caller, q, QueryId::FetchAllChoices, args);
}


void IlmTestHelper::fetchAllQuestions(QObject* caller, QString const& query)
{
    LOGGER(query);
    QString q = "SELECT * FROM questions";
    QVariantList args;

    if ( !query.isEmpty() ) {
        q += " WHERE standard_body LIKE '%' || ? || '%'";
        args << query;
    }

    q += " ORDER BY id DESC";

    m_sql->executeQuery(caller, q, QueryId::FetchAllQuestions, args);
}


void IlmTestHelper::fetchQuestion(QObject* caller, qint64 questionId)
{
    LOGGER(questionId);

    m_sql->executeQuery(caller, QString("SELECT * FROM questions WHERE id=%1").arg(questionId), QueryId::FetchQuestion);
}


void IlmTestHelper::fetchQuestionsForSuitePage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    QStringList fields = QStringList() << "id" << FIELD_SOURCE_ID << "standard_body" << "difficulty";

    for (int i = fields.size()-1; i >= 0; i--) {
        fields[i] = QString("q.%1").arg(fields[i]);
    }

    //m_sql->executeQuery(caller, QString("SELECT %2 FROM questions q LEFT JOIN questions x ON q.source_id=x.id WHERE q.suite_page_id=%1 OR x.suite_page_id=%1").arg(suitePageId).arg( fields.join(",") ), QueryId::FetchQuestionsForSuitePage);
    m_sql->executeQuery(caller, QString("SELECT %2 FROM questions q WHERE q.suite_page_id=%1").arg(suitePageId).arg( fields.join(",") ), QueryId::FetchQuestionsForSuitePage);
}


void IlmTestHelper::fetchChoicesForQuestion(QObject* caller, qint64 questionId)
{
    LOGGER(questionId);

    QStringList fields = QStringList() << "answers.id AS id" << FIELD_VALUE_TEXT << FIELD_SORT_ORDER << "correct";
    m_sql->executeQuery(caller, QString("SELECT %1 FROM answers INNER JOIN choices ON answers.choice_id=choices.id WHERE question_id=%2 ORDER BY %3").arg( fields.join(",") ).arg(questionId).arg(FIELD_SORT_ORDER), QueryId::FetchChoicesForQuestion);
}


void IlmTestHelper::removeAnswer(QObject* caller, qint64 id)
{
    LOGGER(id);
    m_sql->executeDelete(caller, "answers", QueryId::RemoveAnswer, id);
}


void IlmTestHelper::removeChoice(QObject* caller, qint64 id)
{
    LOGGER(id);
    m_sql->executeDelete(caller, "choices", QueryId::RemoveChoice, id);
}


void IlmTestHelper::removeQuestion(QObject* caller, qint64 id)
{
    LOGGER(id);
    m_sql->executeDelete(caller, "questions", QueryId::RemoveQuestion, id);
}


QVariantMap IlmTestHelper::sourceChoice(qint64 originalChoiceId, QString const& value)
{
    LOGGER(value);

    QVariantMap keyValues = TokenHelper::getTokensForChoice(value);
    keyValues[FIELD_SOURCE_ID] = originalChoiceId;
    qint64 id = m_sql->executeInsert("choices", keyValues);
    SET_KEY_VALUE_ID;

    return keyValues;
}


void IlmTestHelper::updateSortOrders(QObject* caller, QVariantList const& qvl)
{
    LOGGER( qvl.size() );

    QMap<qint64,int> result;
    int count = 0;

    for (int i = 0; i < qvl.size(); i++)
    {
        QVariantMap current = qvl[i].toMap();

        if ( current.value("correct").toInt() == 1 ) {
            result[ current["id"].toLongLong() ] = ++count;
        }
    }

    if ( !result.isEmpty() )
    {
        m_sql->startTransaction(caller, QueryId::PendingTransaction);

        foreach ( qint64 id, result.keys() ) {
            m_sql->executeQuery( caller, QString("UPDATE answers SET %1=%2 WHERE id=%3").arg(FIELD_SORT_ORDER).arg( result.value(id) ).arg(id), QueryId::PendingTransaction );
        }

        m_sql->endTransaction(caller, QueryId::UpdateSortOrder);
    }
}


IlmTestHelper::~IlmTestHelper()
{
}

} /* namespace ilmtest */
