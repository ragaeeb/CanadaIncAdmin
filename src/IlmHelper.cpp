#include "precompiled.h"

#include "IlmHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "SharedConstants.h"
#include "TextUtils.h"
#include "TokenHelper.h"

#define FIELD_REPLACE(dest,src,field) QString("%3=(SELECT %3 FROM %2.individuals WHERE %1.individuals.id=%2.individuals.id)").arg(dest).arg(src).arg(field)
#define REPLACE_INDIVIDUAL(input) m_sql->executeQuery(caller, QString(input).arg(actualId).arg(toReplaceId).arg(db), InternalQueryId::PendingTransaction)
#define REPLACE_INDIVIDUAL_FIELD(field) m_sql->executeQuery(caller, QString("UPDATE %2.individuals SET %4=(SELECT %4 FROM %2.individuals WHERE id=%3) WHERE id=%1 AND %4 ISNULL").arg(actualId).arg(db).arg(toReplaceId).arg(field), InternalQueryId::PendingTransaction);

namespace ilm {

using namespace admin;

IlmHelper::IlmHelper(DatabaseHelper* sql) : m_sql(sql)
{
}

void IlmHelper::removeMention(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("mentions", QueryId::RemoveBioLink);
}


void IlmHelper::removeWebsite(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("websites", QueryId::RemoveWebsite);
}


void IlmHelper::removeIndividual(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("individuals", QueryId::RemoveIndividual);
}


void IlmHelper::removeLocation(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("locations", QueryId::RemoveLocation);
}


QVariantMap IlmHelper::addRelation(qint64 individual, qint64 other, int type)
{
    LOGGER(individual << other << type);

    QVariantMap keyValues;
    keyValues["individual"] = individual;
    keyValues["other_id"] = other;
    keyValues["type"] = type;

    qint64 id = m_sql->executeInsert("relationships", keyValues);
    SET_AND_RETURN;
}


void IlmHelper::removeRelation(QObject* caller, qint64 id) {
    REMOVE_ELEMENT("relationships", QueryId::RemoveRelation);
}


void IlmHelper::replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId)
{
    LOGGER(toReplaceId << actualId);

    QString current = databaseName();
    QStringList dbs = QStringList() << current;
    QStringList additional = QStringList() << "arabic";

    foreach (QString const& a, additional)
    {
        if ( QFile::exists( QString("%1/%2.db").arg( QDir::homePath() ).arg( ILM_DB_FILE(a) ) ) ) {
            dbs << ILM_DB_FILE(a);
        }
    }

    LOGGER(dbs);

    for (int i = dbs.size()-1; i >= 0; i--)
    {
        QString db = dbs[i];

        LOGGER(db);
        m_sql->attachIfNecessary(db, true);

        m_sql->startTransaction(caller, InternalQueryId::PendingTransaction);
        REPLACE_INDIVIDUAL("UPDATE %3.mentions SET target=%1 WHERE target=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.quotes SET author=%1 WHERE author=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.suites SET translator=%1 WHERE translator=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.suites SET translator=%1 WHERE translator=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.suites SET explainer=%1 WHERE explainer=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.teachers SET teacher=%1 WHERE teacher=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.teachers SET individual=%1 WHERE individual=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.parents SET parent_id=%1 WHERE parent_id=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.parents SET individual=%1 WHERE individual=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.siblings SET sibling_id=%1 WHERE sibling_id=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.siblings SET individual=%1 WHERE individual=%2");
        REPLACE_INDIVIDUAL("UPDATE %3.websites SET individual=%1 WHERE individual=%2");
        REPLACE_INDIVIDUAL_FIELD("prefix");
        REPLACE_INDIVIDUAL_FIELD("displayName");
        REPLACE_INDIVIDUAL_FIELD("kunya");
        REPLACE_INDIVIDUAL_FIELD("birth");
        REPLACE_INDIVIDUAL_FIELD("death");
        REPLACE_INDIVIDUAL_FIELD("female");
        REPLACE_INDIVIDUAL_FIELD("location");
        REPLACE_INDIVIDUAL_FIELD("current_location");
        REPLACE_INDIVIDUAL_FIELD("is_companion");
        REPLACE_INDIVIDUAL_FIELD("hidden");
        m_sql->executeQuery(caller, QString("UPDATE %2.individuals SET displayName=(SELECT name FROM %2.individuals WHERE id=%3) WHERE id=%1 AND displayName ISNULL").arg(actualId).arg(db).arg(toReplaceId), InternalQueryId::PendingTransaction);
        m_sql->executeQuery(caller, QString("DELETE FROM %2.individuals WHERE id=%1").arg(toReplaceId).arg(db), InternalQueryId::PendingTransaction);
        m_sql->endTransaction(caller, i == 0 ? QueryId::ReplaceIndividual : InternalQueryId::PendingTransaction);

        if (db != current) {
            m_sql->detach(db);
        }
    }
}


void IlmHelper::searchIndividuals(QObject* caller, QVariantList const& params)
{
    LOGGER(params);

    int n = params.size();
    QString query = QString("SELECT id,%1,death,is_companion,hidden,female FROM individuals i WHERE (%2) ").arg( NAME_FIELD("i","display_name") ).arg( NAME_SEARCH_FLAGGED("i", false) );

    if (n > 1) {
        query += QString(" AND (%1)").arg( NAME_SEARCH_FLAGGED("i", false) ).repeated(n-1);
    }

    query += " ORDER BY display_name";

    QVariantList actualParams;

    foreach (QVariant const& p, params) {
        actualParams << p << p << p;
    }

    m_sql->executeQuery(caller, query, QueryId::SearchIndividuals, actualParams);
}


void IlmHelper::searchIndividualsByDeath(QObject* caller, int death)
{
    LOGGER(death);
    m_sql->executeQuery(caller, QString("SELECT id,%1,death,is_companion,hidden,female FROM individuals i WHERE death=%2").arg( NAME_FIELD("i","display_name") ).arg(death), QueryId::SearchIndividuals);
}


void IlmHelper::addMention(QObject* caller, qint64 suitePageId, QVariantList const& targetIds, QVariant const& points)
{
    LOGGER(suitePageId << targetIds << points);

    QString query = "INSERT INTO mentions (target,suite_page_id,points) VALUES(?,?,?)";

    m_sql->startTransaction(caller, InternalQueryId::PendingTransaction);

    foreach (QVariant const& targetId, targetIds) {
        m_sql->executeQuery(caller, query, InternalQueryId::PendingTransaction, QVariantList() << targetId << suitePageId << points);
    }

    m_sql->endTransaction(caller, QueryId::AddMention);
}


QVariantMap IlmHelper::addIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description)
{
    LOGGER( prefix << name << kunya << displayName << birth << death << female << location << level << description );

    QVariantMap keyValues = TokenHelper::getTokensForIndividual(prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, level, description);
    qint64 id = m_sql->executeInsert("individuals", keyValues);
    keyValues["display_name"] = !displayName.isEmpty() ? displayName : name;
    SET_KEY_VALUE_ID;

    return keyValues;
}


QVariantMap IlmHelper::addWebsite(qint64 individualId, QString const& address)
{
    LOGGER(individualId << address);

    QVariantMap keyValues = TokenHelper::getTokensForWebsite(individualId, address);
    qint64 id = m_sql->executeInsert("websites", keyValues);
    SET_AND_RETURN;
}


QVariantMap IlmHelper::addLocation(QString const& city, qreal latitude, qreal longitude)
{
    LOGGER(city << latitude << longitude);

    QVariantMap keyValues = TokenHelper::getTokensForLocation(city, latitude, longitude);
    qint64 id = m_sql->executeInsert("locations", keyValues);
    SET_AND_RETURN;
}


QVariantMap IlmHelper::editMention(QObject* caller, qint64 id, QVariant const& points)
{
    LOGGER(id << points);

    QVariantMap keyValues;
    keyValues["points"] = points;

    m_sql->executeUpdate(caller, "mentions", keyValues, QueryId::EditMention, id);
    SET_AND_RETURN;
}


QVariantMap IlmHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description)
{
    LOGGER( id << prefix << name << kunya << displayName << hidden << birth << death << female << location << currentLocation << level << description.length() );

    QVariantMap keyValues = TokenHelper::getTokensForIndividual(prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, level, description);
    m_sql->executeUpdate(caller, "individuals", keyValues, QueryId::EditIndividual, id);
    keyValues["display_name"] = displayName;
    SET_AND_RETURN;
}


QVariantMap IlmHelper::editLocation(QObject* caller, qint64 id, QString const& city)
{
    LOGGER(id << city);

    QVariantMap keyValues;
    keyValues["city"] = city;

    m_sql->executeUpdate(caller, "locations", keyValues, QueryId::EditLocation, id);
    SET_AND_RETURN;
}


void IlmHelper::fetchAllIndividuals(QObject* caller, bool companionsOnly, QVariant const& knownLocations)
{
    LOGGER(companionsOnly << knownLocations);

    QString query = QString("SELECT i.id,%1,hidden,is_companion,female FROM individuals i").arg( NAME_FIELD("i","display_name") );
    QStringList restrictions;

    if (companionsOnly) {
        restrictions << "is_companion=1";
    }

    if ( knownLocations.isValid() )
    {
        bool knownFlag = knownLocations.toBool();

        if (knownFlag) {
            restrictions << "location > 0";
        } else {
            restrictions << "location ISNULL";
        }
    }

    if ( !restrictions.isEmpty() ) {
        query += QString(" WHERE %1").arg( restrictions.join(" AND ") );
    }

    m_sql->executeQuery(caller, query, QueryId::FetchAllIndividuals);
}


void IlmHelper::fetchAllLocations(QObject* caller, QString const& city)
{
    LOGGER(city);
    QString q = "SELECT * FROM locations";

    QVariantList args;

    if ( !city.isEmpty() ) {
        q += " WHERE city LIKE '%' || ? || '%'";
        args << city;
    }

    q += " ORDER BY city";

    m_sql->executeQuery(caller, q, QueryId::FetchAllLocations, args);
}


void IlmHelper::fetchBioMetadata(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    m_sql->executeQuery(caller, QString("SELECT mentions.id,%1,points,mentions.target AS target_id FROM mentions LEFT JOIN individuals i ON mentions.target=i.id WHERE suite_page_id=%2").arg( NAME_FIELD("i","target") ).arg(suitePageId), QueryId::FetchBioMetadata);
}


void IlmHelper::fetchRelations(QObject* caller, qint64 individual)
{
    LOGGER(individual);
    m_sql->executeQuery(caller, QString("SELECT i.id AS id,individual,other_id,%1,i.female AS female,type FROM relationships INNER JOIN individuals i ON relationships.individual=i.id WHERE relationships.other_id=%2 UNION SELECT i.id,individual,other_id,%1,i.female,type FROM relationships INNER JOIN individuals i ON relationships.other_id=i.id WHERE relationships.individual=%2").arg( NAME_FIELD("i","name") ).arg(individual), QueryId::FetchRelations);
}


void IlmHelper::fetchFrequentIndividuals(QObject* caller, QString const& table, QString const& field, int n, QString const& where)
{
    QStringList innerParts;

    if ( !where.isEmpty() ) {
        innerParts << QString("WHERE %1").arg(where);
    }

    innerParts << QString("GROUP BY %1").arg(field) << "ORDER BY n DESC" << QString("LIMIT %1").arg(n);

    QString innerClause = QString("SELECT %1,COUNT(%1) AS n FROM %2 %3").arg(field).arg(table).arg( innerParts.join(" ") );

    m_sql->executeQuery(caller, QString("SELECT %1 AS id,%2,is_companion,female FROM (%3) INNER JOIN individuals i ON i.id=%1 GROUP BY i.id ORDER BY display_name").arg(field).arg( NAME_FIELD("i","display_name") ).arg(innerClause), QueryId::FetchAllIndividuals);
}


void IlmHelper::fetchAllWebsites(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT id,uri FROM websites WHERE individual=%1 ORDER BY uri").arg(individualId), QueryId::FetchAllWebsites);
}


void IlmHelper::fetchIndividualData(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QString query = QString("SELECT individuals.id,prefix,name,kunya,hidden,birth,death,female,displayName,location,is_companion,x.city,notes,current_location,y.city AS current_city FROM individuals LEFT JOIN locations x ON individuals.location=x.id LEFT JOIN locations y ON individuals.current_location=y.id WHERE individuals.id=%1").arg(individualId);
    m_sql->executeQuery(caller, query, QueryId::FetchIndividualData);
}


void IlmHelper::fetchMentions(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT mentions.id,%1,heading,title,suite_page_id,suites.reference,suite_pages.reference AS suite_page_reference,COALESCE(points,0) AS points,suite_pages.suite_id FROM mentions INNER JOIN suite_pages ON mentions.suite_page_id=suite_pages.id INNER JOIN suites ON suites.id=suite_pages.suite_id LEFT JOIN individuals i ON suites.author=i.id WHERE target=%2").arg( NAME_FIELD("i","author") ).arg(individualId), QueryId::FetchMentions);
}


void IlmHelper::lazyInit()
{
}


void IlmHelper::portIndividuals(QObject* caller, QString destinationLanguage)
{
    QString srcLanguage = databaseName();
    destinationLanguage = ILM_DB_FILE(destinationLanguage);
    m_sql->attachIfNecessary(destinationLanguage, true);

    m_sql->startTransaction(caller, InternalQueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("UPDATE %1.individuals SET %2,%3,%4,%5").arg(destinationLanguage)
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "prefix") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "name") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "kunya") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "hidden") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "birth") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "death") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "female") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "location") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "current_location") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "is_companion") ), InternalQueryId::PendingTransaction);

    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.locations SELECT * FROM %2.locations WHERE id NOT IN (SELECT id FROM %1.locations)").arg(destinationLanguage).arg(srcLanguage), InternalQueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.individuals SELECT * FROM %2.individuals WHERE id NOT IN (SELECT id FROM %1.individuals)").arg(destinationLanguage).arg(srcLanguage), InternalQueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("DELETE FROM %1.individuals WHERE id NOT IN (SELECT id FROM %2.individuals)").arg(destinationLanguage).arg(srcLanguage), InternalQueryId::PendingTransaction);
    m_sql->endTransaction(caller, QueryId::PortIndividuals);

    m_sql->detach(destinationLanguage);
}


void IlmHelper::setDatabaseName(QString const& name) {
    m_name = name;
}


QString IlmHelper::databaseName() const {
    return m_name;
}


IlmHelper::~IlmHelper()
{
}

} /* namespace ilm */
