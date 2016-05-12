#include "precompiled.h"

#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "SalatHelper.h"

namespace {

QVariantMap getTokensForCenter(QString const& name, QString const& website, qint64 location)
{
    QVariantMap keyValues;
    keyValues["name"] = name;
    /*keyValues["hidden"] = hidden;
    keyValues["launched"] = launched; */
    keyValues["website"] = website;
    /*keyValues["email"] = email;
    keyValues["description"] = description; */
    keyValues["location"] = location;

    return keyValues;
}

QVariantMap getTokensForTags(qint64 suitePageId, QString const& tag)
{
    QVariantMap keyValues;
    keyValues["suite_page_id"] = suitePageId;
    keyValues["tag"] = tag;

    return keyValues;
}

}

namespace admin {

using namespace canadainc;

SalatHelper::SalatHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


QVariantMap SalatHelper::addCenter(QString const& name, QString const& website, qint64 location)
{
    LOGGER(name << website << location);

    QVariantMap keyValues = getTokensForCenter(name, website, location);
    qint64 id = m_sql->executeInsert("masjids", keyValues);
    SET_AND_RETURN;
}


QVariantMap SalatHelper::editCenter(QObject* caller, qint64 id, QString const& name, QString const& website, qint64 location)
{
    LOGGER(id << name << website << location);

    QVariantMap keyValues = getTokensForCenter(name, website, location);
    m_sql->executeUpdate(caller, "masjids", keyValues, QueryId::EditCenter, id);
    SET_AND_RETURN;
}


QVariantMap SalatHelper::editTag(QObject* caller, qint64 id, QString const& tag, QString const& table)
{
    LOGGER(id << tag);

    QVariantMap keyValues;
    keyValues["tag"] = tag;

    m_sql->executeUpdate(caller, table, keyValues, QueryId::EditTag, id);
    SET_AND_RETURN;
}


void SalatHelper::fetchAllCenters(QObject* caller, QString const& name)
{
    QString q = "SELECT * FROM masjids";

    QVariantList args;

    if ( !name.isEmpty() ) {
        q += " WHERE name LIKE '%' || ? || '%'";
        args << name;
    }

    q += " ORDER BY name";

    m_sql->executeQuery(caller, q, QueryId::FetchAllCenters, args);
}


void SalatHelper::fetchCenter(QObject* caller, qint64 id)
{
    LOGGER(id);

    QString query = QString("SELECT masjids.id,masjids.name,hidden,launched,website,email,description,location,locations.city AS location_name FROM masjids INNER JOIN locations ON masjids.location=locations.id WHERE masjids.id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::FetchCenter);
}


void SalatHelper::fetchTagsForSuitePage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("SELECT id,tag FROM grouped_suite_pages WHERE suite_page_id=%1 ORDER BY tag").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::FetchTagsForSuitePage);
}


void SalatHelper::removeTag(QObject* caller, qint64 id, QString const& table)
{
    LOGGER(id);
    REMOVE_ELEMENT(table, QueryId::RemoveTag);
}


void SalatHelper::searchTags(QObject* caller, QString const& term, QString const& table)
{
    LOGGER(term);

    QVariantList params;
    QString query = "SELECT DISTINCT(tag) FROM "+table;

    if ( !term.isEmpty() )
    {
        query += QString(" WHERE %1").arg( LIKE_CLAUSE("tag") );
        params << term;
    }

    query += " ORDER BY tag";

    m_sql->executeQuery(caller, query, QueryId::SearchTags, params);
}


QVariantMap SalatHelper::tagSuitePage(qint64 const& suitePageId, QString const& tag)
{
    LOGGER(suitePageId << tag);

    QVariantMap keyValues = getTokensForTags(suitePageId, tag);
    qint64 id = m_sql->executeInsert("grouped_suite_pages", keyValues);
    SET_AND_RETURN;
}


void SalatHelper::tagSuites(QObject* caller, QVariantList const& suiteIds, QString const& tag)
{
    LOGGER(suiteIds << tag);

    m_sql->startTransaction(caller, InternalQueryId::PendingTransaction);

    foreach (QVariant const& suiteId, suiteIds) {
        m_sql->executeQuery(caller, QString("INSERT INTO grouped_suite_pages (suite_page_id,tag) SELECT id,'%1' FROM suite_pages WHERE suite_id=?").arg(tag), InternalQueryId::PendingTransaction, QVariantList() << suiteId);
    }

    m_sql->endTransaction(caller, QueryId::TagSuites);
}


void SalatHelper::lazyInit()
{
}


SalatHelper::~SalatHelper()
{
}

} /* namespace ilm */
