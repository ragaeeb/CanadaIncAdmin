#include "precompiled.h"

#include "TafsirHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "SharedConstants.h"
#include "TokenHelper.h"

namespace admin {

using namespace canadainc;

TafsirHelper::TafsirHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


QVariantMap TafsirHelper::addQuote(qint64 authorId, qint64 translatorId, QString const& body, QString const& reference, qint64 suiteId, QString const& uri)
{
    LOGGER(authorId << translatorId << suiteId);

    QVariantMap keyValues = TokenHelper::getTokensForQuote(authorId, translatorId, body, reference, suiteId, uri);
    qint64 id = m_sql->executeInsert("quotes", keyValues);
    SET_AND_RETURN;
}


QVariantMap TafsirHelper::addSuite(qint64 author, qint64 translator, qint64 explainer, QString const& title, QString const& description, QString const& reference, bool isBook)
{
    LOGGER(author << translator << explainer << title << description << reference << isBook);

    QVariantMap keyValues = TokenHelper::getTokensForSuite(author, translator, explainer, title, description, reference, isBook);
    qint64 id = m_sql->executeInsert("suites", keyValues);
    SET_AND_RETURN;
}


QVariantMap TafsirHelper::addSuitePage(qint64 suiteId, QString const& body, QString const& heading, QString const& reference)
{
    LOGGER( suiteId << body.length() << heading.length() << reference.length() );

    QVariantMap keyValues = TokenHelper::getTokensForSuitePage(suiteId, body, heading, reference);
    qint64 id = m_sql->executeInsert("suite_pages", keyValues);
    SET_AND_RETURN;
}


QVariantMap TafsirHelper::editSuite(QObject* caller, qint64 id, qint64 author, qint64 translator, qint64 explainer, QString const& title, QString const& description, QString const& reference, bool isBook)
{
    LOGGER(id << author << translator << explainer << title << description << reference << isBook);

    QVariantMap keyValues = TokenHelper::getTokensForSuite(author, translator, explainer, title, description, reference, isBook);
    m_sql->executeUpdate(caller, "suites", keyValues, QueryId::EditSuite, id);
    SET_AND_RETURN;
}


QVariantMap TafsirHelper::editSuitePage(QObject* caller, qint64 id, QString const& body, QString const& heading, QString const& reference)
{
    LOGGER( id << body.length() << heading.length() << reference.length() );

    QVariantMap keyValues = TokenHelper::getTokensForSuitePage(0, body, heading, reference);
    keyValues.remove("suite_id");
    m_sql->executeUpdate(caller, "suite_pages", keyValues, QueryId::EditSuitePage, id);
    SET_AND_RETURN;
}


QVariantMap TafsirHelper::editQuote(QObject* caller, qint64 id, qint64 author, qint64 translator, QString const& body, QString const& reference, qint64 suiteId, QString const& uri)
{
    LOGGER(id << author << translator << body << reference << suiteId << uri);

    QVariantMap keyValues = TokenHelper::getTokensForQuote(author, translator, body, reference, suiteId, uri);
    m_sql->executeUpdate(caller, "quotes", keyValues, QueryId::EditQuote, id);
    SET_AND_RETURN;
}


void TafsirHelper::fetchAllTafsir(QObject* caller, qint64 id, qint64 author, int limit)
{
    LOGGER(id);

    QStringList queryParams = QStringList() << QString("SELECT suites.id AS id,%1,title,is_book FROM suites LEFT JOIN individuals i ON i.id=suites.author").arg( NAME_FIELD("i","author") );
    QStringList where;

    if (id) {
        where << QString("suites.id=%1").arg(id);
    }

    if (author) {
        where << QString("suites.author=%1").arg(author);
        where << QString("suites.explainer=%1").arg(author);
        where << QString("suites.translator=%1").arg(author);
    }

    if ( !where.isEmpty() ) {
        queryParams << QString("WHERE %1").arg( where.join(" OR ") );
    }

    queryParams << "ORDER BY id DESC" << QString("LIMIT %1").arg(limit);

    m_sql->executeQuery(caller, queryParams.join(" "), QueryId::FetchAllTafsir);
}


void TafsirHelper::fetchSuitePageIntersection(QObject* caller, QString other)
{
    LOGGER(other);
    other = ILM_DB_FILE(other);
    m_sql->attachIfNecessary(other, true);
    m_sql->executeQuery(caller, QString("SELECT x.suite_id AS id FROM %1.suite_pages x INNER JOIN %2.suite_pages y ON x.id=y.id AND x.suite_id=y.suite_id").arg( databaseName() ).arg(other), QueryId::FetchSuitePageIntersection);
    m_sql->detach(other);
}


void TafsirHelper::findDuplicateSuites(QObject* caller, QString const& field)
{
    LOGGER(field);

    QString query = QString("SELECT suites.id AS id,%1,title,COUNT(*) c FROM suites LEFT JOIN individuals i ON i.id=suites.author GROUP BY %2 HAVING c > 1").arg( NAME_FIELD("i","author") ).arg(field);
    m_sql->executeQuery(caller, query, QueryId::FindDuplicates);
}


void TafsirHelper::fetchTafsirMetadata(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("SELECT author,translator,explainer,title,description,reference,is_book FROM suites WHERE id=%1").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::FetchTafsirHeader);
}


void TafsirHelper::fetchTafsirContent(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    QString query = QString("SELECT reference,body,heading FROM suite_pages WHERE suite_pages.id=%1").arg(suitePageId);

    m_sql->executeQuery(caller, query, QueryId::FetchTafsirContent);
}


void TafsirHelper::fetchAllQuotes(QObject* caller, qint64 id, qint64 author, int limit)
{
    LOGGER(id);

    QStringList queryParams = QStringList() << QString("SELECT quotes.id AS id,%1,%2,body,quotes.reference,title FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN individuals j ON j.id=quotes.translator LEFT JOIN suites ON quotes.suite_id=suites.id").arg( NAME_FIELD("i","author") ).arg( NAME_FIELD("j","translator") );

    QStringList whereClauses;

    if (id) {
        whereClauses << QString("quotes.id=%1").arg(id);
    }

    if (author) {
        whereClauses << QString("quotes.author=%1").arg(author);
    }

    if ( !whereClauses.isEmpty() ) {
        queryParams << QString("WHERE %1").arg( whereClauses.join(" AND ") );
    }

    queryParams << "ORDER BY id DESC";

    if (limit > 0) {
        queryParams << QString("LIMIT %1").arg(limit);
    }

    m_sql->executeQuery(caller, queryParams.join(" "), QueryId::FetchAllQuotes);
}


void TafsirHelper::lazyInit()
{
}


void TafsirHelper::findDuplicateQuotes(QObject* caller, QString const& field)
{
    LOGGER(field);

    QString query = QString("SELECT quotes.id AS id,%1,body,reference,COUNT(*) c FROM quotes INNER JOIN individuals i ON i.id=quotes.author GROUP BY %2 HAVING c > 1").arg( NAME_FIELD("i","author") ).arg(field);
    m_sql->executeQuery(caller, query, QueryId::FindDuplicates);
}


void TafsirHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("SELECT id,body,heading,reference FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}


void TafsirHelper::fetchQuote(QObject* caller, qint64 id)
{
    LOGGER(id);

    QString query = QString("SELECT quotes.author AS author_id,quotes.translator AS translator_id,body,reference,suite_id,uri FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE quotes.id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::FetchQuote);
}


void TafsirHelper::mergeSuites(QObject* caller, QVariantList const& toReplaceIds, qint64 actualId)
{
    LOGGER(toReplaceIds << actualId);

    m_sql->startTransaction(caller, InternalQueryId::PendingTransaction);

    foreach (QVariant const& q, toReplaceIds)
    {
        qint64 toReplaceId = q.toLongLong();

        m_sql->executeQuery(caller, QString("UPDATE suite_pages SET suite_id=%1,heading=(SELECT title FROM suites WHERE id=%2),reference=(SELECT reference FROM suites WHERE id=%2) WHERE suite_id=%2").arg(actualId).arg(toReplaceId), InternalQueryId::PendingTransaction);
        m_sql->executeQuery(caller, QString("UPDATE quotes SET suite_id=%1 WHERE suite_id=%2").arg(actualId).arg(toReplaceId), InternalQueryId::PendingTransaction);
        m_sql->executeQuery(caller, QString("DELETE FROM suites WHERE id=%1").arg(toReplaceId), InternalQueryId::PendingTransaction);
    }

    m_sql->endTransaction(caller, QueryId::ReplaceSuite);
}


void TafsirHelper::moveToSuite(QObject* caller, qint64 suitePageId, qint64 destSuiteId)
{
    LOGGER(suitePageId << destSuiteId);

    m_sql->executeQuery(caller, "UPDATE suite_pages SET suite_id=? WHERE id=?", QueryId::MoveToSuite, QVariantList() << destSuiteId << suitePageId);
}


void TafsirHelper::removeQuote(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("quotes", QueryId::RemoveQuote);
}


void TafsirHelper::removeSuite(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("suites", QueryId::RemoveSuite);
}


void TafsirHelper::removeSuitePage(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("suite_pages", QueryId::RemoveSuitePage);
}


void TafsirHelper::searchQuote(QObject* caller, QString fieldName, QString const& searchTerm)
{
    LOGGER(fieldName << searchTerm);

    QString query;
    QVariantList args = QVariantList() << searchTerm;

    if (fieldName == "author")
    {
        query = QString("SELECT quotes.id,%1,%3,body,quotes.reference,title FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN individuals j ON j.id=quotes.translator LEFT JOIN suites ON suites.id=quotes.suite_id WHERE %2 OR %4 ORDER BY quotes.id DESC").arg( NAME_FIELD("i","author") ).arg( NAME_SEARCH("i") ).arg( NAME_FIELD("j","translator") ).arg( NAME_SEARCH("j") );

        for (int i = 0; i < 5; i++) {
            args << searchTerm;
        }
    } else {
        query = QString("SELECT quotes.id,%2,%3,body,quotes.reference,title FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN individuals j ON j.id=quotes.translator LEFT JOIN suites ON suites.id=quotes.suite_id WHERE %1 LIKE '%' || ? || '%' ORDER BY quotes.id DESC").arg(fieldName).arg( NAME_FIELD("i","author") ).arg( NAME_FIELD("j","translator") );
    }

    m_sql->executeQuery(caller, query, QueryId::SearchQuote, args);
}


void TafsirHelper::searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm)
{
    LOGGER(fieldName << searchTerm);

    QStringList fields = QStringList() << "suites.id AS id" << NAME_FIELD("i", "author") << "title" << "is_book";
    QStringList where;
    QStringList joins;
    QString query;
    QVariantList args;

    if (fieldName == "title") {
        query = QString("SELECT %1,NULL AS heading,NULL AS suite_page_id FROM suites LEFT JOIN individuals i ON i.id=suites.author WHERE %2 UNION SELECT %1,heading,suite_pages.id AS suite_page_id FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suite_pages.suite_id=suites.id WHERE %3").arg( fields.join(",") ).arg( LIKE_CLAUSE("title") ).arg( LIKE_CLAUSE("heading") );
        args << searchTerm << searchTerm;
    } else {
        if (fieldName == "description") {
            where << LIKE_CLAUSE(fieldName);
        } else {
            if (fieldName == "body") {
                where << LIKE_CLAUSE("body");
            } else if (fieldName == "reference") {
                where << LIKE_CLAUSE("suite_pages.reference") << LIKE_CLAUSE("suites.reference");
            }

            joins << "INNER JOIN suite_pages ON suites.id=suite_pages.suite_id";
            fields << "heading" << "suite_pages.id AS suite_page_id";
        }

        foreach (QString const& w, where)
        {
            Q_UNUSED(w);
            args << searchTerm;
        }

        query = QString("SELECT %1 FROM suites LEFT JOIN individuals i ON i.id=suites.author %2 WHERE %3 ORDER BY suites.id DESC").arg( fields.join(",") ).arg( joins.join(" ") ).arg( where.join(" OR ") );
    }

    m_sql->executeQuery(caller, query, QueryId::SearchTafsir, args);
}


void TafsirHelper::translateQuote(QObject* caller, qint64 quoteId, QString destinationLanguage)
{
    LOGGER(quoteId << destinationLanguage);

    destinationLanguage = ILM_DB_FILE(destinationLanguage);
    m_sql->attachIfNecessary(destinationLanguage, true);

    m_sql->startTransaction(caller, InternalQueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.quotes (english_id,author,body,reference,uri) SELECT id,author,body,reference,uri FROM quotes WHERE id=%2").arg(destinationLanguage).arg(quoteId), InternalQueryId::PendingTransaction);
    m_sql->endTransaction(caller, QueryId::TranslateQuote);

    m_sql->detach(destinationLanguage);
}


void TafsirHelper::translateSuitePage(QObject* caller, qint64 suitePageId, QString destinationLanguage)
{
    LOGGER(suitePageId << destinationLanguage);

    destinationLanguage = ILM_DB_FILE(destinationLanguage);
    m_sql->attachIfNecessary(destinationLanguage, true);

    m_sql->startTransaction(caller, InternalQueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.suites(id,author,explainer,title,description,reference) SELECT id,author,explainer,title,description,reference FROM suites WHERE id=(SELECT suite_id FROM suite_pages WHERE id=%2)").arg(destinationLanguage).arg(suitePageId), InternalQueryId::PendingTransaction); // don't port the translator
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.suite_pages(id,suite_id,body) SELECT id,suite_id,body FROM suite_pages WHERE id=%2").arg(destinationLanguage).arg(suitePageId), InternalQueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.mentions SELECT * FROM mentions WHERE suite_page_id=%2").arg(destinationLanguage).arg(suitePageId), InternalQueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.explanations(surah_id,from_verse_number,to_verse_number,suite_page_id) SELECT surah_id,from_verse_number,to_verse_number,suite_page_id FROM explanations WHERE suite_page_id=%2").arg(destinationLanguage).arg(suitePageId), InternalQueryId::PendingTransaction);
    m_sql->endTransaction(caller, QueryId::TranslateSuitePage);

    m_sql->detach(destinationLanguage);
}


void TafsirHelper::setDatabaseName(QString const& name) {
    m_name = name;
}


QString TafsirHelper::databaseName() const {
    return m_name;
}


TafsirHelper::~TafsirHelper()
{
}

} /* namespace admin */
