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


void SalatHelper::lazyInit()
{
}


SalatHelper::~SalatHelper()
{
}

} /* namespace ilm */
