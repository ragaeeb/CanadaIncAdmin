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

    QString query = QString("SELECT grouped_suite_pages.tag AS id,name FROM grouped_suite_pages INNER JOIN tags ON grouped_suite_pages.tag=tags.id WHERE suite_page_id=%1 ORDER BY name").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::FetchTagsForSuitePage);
}


void SalatHelper::removeTag(QObject* caller, qint64 id, QString const& table)
{
    LOGGER(id);
    m_sql->executeQuery( caller, QString("DELETE FROM %1 WHERE %2=%3").arg(table).arg("tag").arg(id), QueryId::RemoveTag );
}


QVariantMap SalatHelper::createTag(QString const& name)
{
    QVariantMap keyValues;
    keyValues["name"] = name;

    qint64 id = m_sql->executeInsert("tags", keyValues);
    SET_AND_RETURN;
}


void SalatHelper::searchTags(QObject* caller, QString const& term)
{
    LOGGER(term);

    QVariantList params;
    QString query = QString("SELECT id,name FROM tags WHERE %1 ORDER BY name").arg( LIKE_CLAUSE("name") );
    params << term;

    m_sql->executeQuery(caller, query, QueryId::SearchTags, params);
}


QVariantMap SalatHelper::tagSuitePage(qint64 const& suitePageId, int tag)
{
    LOGGER(suitePageId << tag);

    QVariantMap keyValues;
    keyValues["suite_page_id"] = suitePageId;
    keyValues["tag"] = tag;

    qint64 id = m_sql->executeInsert("grouped_suite_pages", keyValues);
    SET_AND_RETURN;
}


void SalatHelper::lazyInit()
{
}


SalatHelper::~SalatHelper()
{
}

} /* namespace ilm */
