#include "precompiled.h"

#include "IlmHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "TextUtils.h"
#include "TokenHelper.h"

#define FIELD_REPLACE(dest,src,field) QString("%3=(SELECT %3 FROM %2.individuals WHERE %1.individuals.id=%2.individuals.id)").arg(dest).arg(src).arg(field)
#define KEY_DEATH "death"
#define KEY_KUNYA "kunya"
#define KEY_NAME "name"
#define KEY_PREFIX "prefix"
#define NAME_SEARCH_FLAGGED(var, startsWith) QString("%1.name LIKE %2 ? || '%' OR %1.displayName LIKE %2 ? || '%' OR %1.kunya LIKE %2 ? || '%'").arg(var).arg(startsWith ? "" : "'%' ||")
#define NAME_SEARCH(var) NAME_SEARCH_FLAGGED(var, false)
#define REPLACE_INDIVIDUAL(input) m_sql->executeQuery(caller, QString(input).arg(actualId).arg(toReplaceId).arg(db), QueryId::PendingTransaction)
#define REPLACE_INDIVIDUAL_FIELD(field) m_sql->executeQuery(caller, QString("UPDATE %2.individuals SET %4=(SELECT %4 FROM %2.individuals WHERE id=%3) WHERE id=%1 AND %4 ISNULL").arg(actualId).arg(db).arg(toReplaceId).arg(field), QueryId::PendingTransaction);

namespace ilm {

using namespace admin;

IlmHelper::IlmHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


void IlmHelper::fetchAllIds(QObject* caller, QString const& table)
{
    LOGGER(table);
    m_sql->executeQuery(caller, QString("SELECT id,'%1' AS table_name FROM %1 ORDER BY id").arg(table), QueryId::FetchAllIds);
}


void IlmHelper::setIndexAsId(QObject* caller, QVariantList const& data, QVariantList const& intersection)
{
    LOGGER( data.size() << intersection.size() );

    QSet<qint64> commonIds;

    foreach (QVariant q, intersection) {
        commonIds << q.toMap().value("id").toLongLong();
    }

    m_sql->startTransaction(caller, QueryId::PendingTransaction);

    QString dbName = databaseName();

    for (int i = 0; i < data.size(); i++)
    {
        QVariantMap current = data[i].toMap();
        QString table = current.value("table_name").toString();
        qint64 id = current.value("id").toLongLong();
        qint64 target = i+1;

        if ( id != target && !commonIds.contains(id) ) {
            m_sql->executeQuery(caller, QString("UPDATE %4.%1 SET id=%3 WHERE id=%2").arg(table).arg(id).arg(target).arg(dbName), QueryId::PendingTransaction);
        }
    }

    m_sql->endTransaction(caller, QueryId::UpdateIdWithIndex);
}


qint64 IlmHelper::generateIndividualField(QObject* caller, QString const& value)
{
    if ( QRegExp("\\d+").exactMatch(value) ) {
        return value.toLongLong();
    } else {
        qint64 id = QDateTime::currentMSecsSinceEpoch();
        QVariantMap parsed = parseName(value);

        m_sql->executeQuery(caller, QString("INSERT INTO individuals (id,prefix,kunya,name) VALUES (?,?,?,?)"), QueryId::AddIndividual, QVariantList() << id << parsed.value(KEY_PREFIX) << parsed.value(KEY_KUNYA) << parsed.value(KEY_NAME));
        return id;
    }
}


void IlmHelper::removeBioLink(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM mentions WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveBioLink);
}


void IlmHelper::removeWebsite(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM websites WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveWebsite);
}


void IlmHelper::removeIndividual(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM individuals WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveIndividual);
}


void IlmHelper::removeLocation(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM locations WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveLocation);
}


void IlmHelper::removeTeacher(QObject* caller, qint64 individual, qint64 teacherId)
{
    LOGGER(individual << teacherId);

    QString query = QString("DELETE FROM teachers WHERE individual=%1 AND teacher=%2").arg(individual).arg(teacherId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTeacher);
}


void IlmHelper::removeParent(QObject* caller, qint64 individual, qint64 parentId)
{
    LOGGER(individual << parentId);

    QString query = QString("DELETE FROM parents WHERE individual=%1 AND parent_id=%2").arg(individual).arg(parentId);
    m_sql->executeQuery(caller, query, QueryId::RemoveParent);
}


void IlmHelper::removeSibling(QObject* caller, qint64 individual, qint64 sibling)
{
    LOGGER(individual << sibling);

    QString query = QString("DELETE FROM siblings WHERE individual=%1 AND sibling_id=%2").arg(individual).arg(sibling);
    m_sql->executeQuery(caller, query, QueryId::RemoveSibling);
}


void IlmHelper::removeChild(QObject* caller, qint64 individual, qint64 childId)
{
    LOGGER(individual << childId);

    QString query = QString("DELETE FROM parents WHERE parent_id=%1 AND individual=%2").arg(individual).arg(childId);
    m_sql->executeQuery(caller, query, QueryId::RemoveChild);
}



void IlmHelper::removeStudent(QObject* caller, qint64 individual, qint64 studentId)
{
    LOGGER(individual << studentId);

    QString query = QString("DELETE FROM teachers WHERE teacher=%1 AND individual=%2").arg(individual).arg(studentId);
    m_sql->executeQuery(caller, query, QueryId::RemoveStudent);
}


void IlmHelper::replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId)
{
    LOGGER(toReplaceId << actualId);

    QString current = databaseName();
    QStringList dbs = QStringList() << current;
    QStringList additional = QStringList() << "arabic";

    foreach (QString const& a, additional)
    {
        if ( QFile::exists( QString("%1/%2.db").arg( QDir::homePath() ).arg( QURAN_TAFSIR_FILE(a) ) ) ) {
            dbs << QURAN_TAFSIR_FILE(a);
        }
    }

    LOGGER(dbs);

    for (int i = dbs.size()-1; i >= 0; i--)
    {
        QString db = dbs[i];

        LOGGER(db);
        m_sql->attachIfNecessary(db, true);

        m_sql->startTransaction(caller, QueryId::PendingTransaction);
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
        REPLACE_INDIVIDUAL_FIELD("is_companion");
        REPLACE_INDIVIDUAL_FIELD("hidden");
        m_sql->executeQuery(caller, QString("UPDATE %2.individuals SET displayName=(SELECT name FROM %2.individuals WHERE id=%3) WHERE id=%1 AND displayName ISNULL").arg(actualId).arg(db).arg(toReplaceId), QueryId::PendingTransaction);
        m_sql->executeQuery(caller, QString("DELETE FROM %2.individuals WHERE id=%1").arg(toReplaceId).arg(db), QueryId::PendingTransaction);
        m_sql->endTransaction(caller, i == 0 ? QueryId::ReplaceIndividual : QueryId::PendingTransaction);

        if (db != current) {
            m_sql->detach(db);
        }
    }
}


void IlmHelper::searchIndividuals(QObject* caller, QString const& trimmedText, QString const& andConstraint, bool startsWith)
{
    LOGGER(trimmedText << andConstraint << startsWith);

    if ( QRegExp("\\d+$").exactMatch(trimmedText) ) {
        m_sql->executeQuery(caller, QString("SELECT id,%1 AS display_name,is_companion,hidden,female FROM individuals i WHERE death=? ORDER BY display_name").arg( NAME_FIELD("i") ), QueryId::SearchIndividuals, QVariantList() << trimmedText);
    } else if ( andConstraint.isEmpty() ) {
        m_sql->executeQuery(caller, QString("SELECT id,%2 AS display_name,is_companion,hidden,female FROM individuals i WHERE %1 ORDER BY display_name").arg( NAME_SEARCH_FLAGGED("i", startsWith) ).arg( NAME_FIELD("i") ), QueryId::SearchIndividuals, QVariantList() << trimmedText << trimmedText << trimmedText);
    } else {
        m_sql->executeQuery(caller, QString("SELECT id,%2 AS display_name,is_companion,hidden,female FROM individuals i WHERE ((%1) AND (%3)) ORDER BY display_name").arg( NAME_SEARCH_FLAGGED("i", startsWith) ).arg( NAME_FIELD("i") ).arg( NAME_SEARCH("i") ), QueryId::SearchIndividuals, QVariantList() << trimmedText << trimmedText << trimmedText << andConstraint << andConstraint << andConstraint);
    }
}


void IlmHelper::addBioLink(QObject* caller, qint64 suitePageId, QVariantList const& targetIds, QVariant const& points)
{
    LOGGER(suitePageId << targetIds << points);

    QString query = "INSERT INTO mentions (target,suite_page_id,points) VALUES(?,?,?)";

    m_sql->startTransaction(caller, QueryId::PendingTransaction);

    foreach (QVariant const& targetId, targetIds) {
        m_sql->executeQuery(caller, query, QueryId::PendingTransaction, QVariantList() << targetId << suitePageId << points);
    }

    m_sql->endTransaction(caller, QueryId::AddBioLink);
}


void IlmHelper::addWebsite(QObject* caller, qint64 individualId, QString const& address)
{
    LOGGER(individualId << address);
    QString query = QString("INSERT INTO websites (individual,uri) VALUES(%1,?)").arg(individualId);
    m_sql->executeQuery(caller, query, QueryId::AddWebsite, QVariantList() << address);
}


qint64 IlmHelper::addLocation(QObject* caller, QString const& city, qreal latitude, qreal longitude)
{
    LOGGER(city << latitude << longitude);

    qint64 now = QDateTime::currentMSecsSinceEpoch();

    QString query = "INSERT INTO locations (id,city,latitude,longitude) VALUES(?,?,?,?)";
    m_sql->executeQuery(caller, query, QueryId::AddLocation, QVariantList() << now << city << latitude << longitude);

    return now;
}


void IlmHelper::addChild(QObject* caller, qint64 parentId, qint64 childId)
{
    LOGGER(parentId << childId);

    QString query = QString("INSERT OR IGNORE INTO parents(parent_id,individual) VALUES(%1,%2)").arg(parentId).arg(childId);
    m_sql->executeQuery(caller, query, QueryId::AddChild);
}


void IlmHelper::addStudent(QObject* caller, qint64 teacherId, qint64 studentId)
{
    LOGGER(teacherId << studentId);

    QString query = QString("INSERT OR IGNORE INTO teachers(teacher,individual) VALUES(%1,%2)").arg(teacherId).arg(studentId);
    m_sql->executeQuery(caller, query, QueryId::AddStudent);
}


void IlmHelper::addTeacher(QObject* caller, qint64 studentId, qint64 teacherId)
{
    LOGGER(studentId << teacherId);

    QString query = QString("INSERT OR IGNORE INTO teachers(individual,teacher) VALUES(%1,%2)").arg(studentId).arg(teacherId);
    m_sql->executeQuery(caller, query, QueryId::AddTeacher);
}


void IlmHelper::addParent(QObject* caller, qint64 childId, qint64 parentId)
{
    LOGGER(childId << parentId);

    QString query = QString("INSERT OR IGNORE INTO parents(individual,parent_id) VALUES(%1,%2)").arg(childId).arg(parentId);
    m_sql->executeQuery(caller, query, QueryId::AddParent);
}


void IlmHelper::addSibling(QObject* caller, qint64 individualId, qint64 siblingId)
{
    LOGGER(individualId << siblingId);

    QString query = QString("INSERT OR IGNORE INTO siblings(individual,sibling_id) VALUES(%1,%2)").arg(individualId).arg(siblingId);
    m_sql->executeQuery(caller, query, QueryId::AddSibling);
}


void IlmHelper::editBioLink(QObject* caller, qint64 id, QVariant const& points)
{
    LOGGER(id << points);

    QString query = "UPDATE mentions SET points=? WHERE id=?";

    m_sql->executeQuery( caller, query, QueryId::EditBioLink, QVariantList() << points << id );
}


QVariantMap IlmHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description)
{
    LOGGER( id << prefix << name << kunya << displayName << hidden << birth << death << female << location << currentLocation << level << description.length() );

    QVariantMap keyValues = TokenHelper::getTokensForIndividual(prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, level, description);
    m_sql->executeUpdate(caller, "individuals", keyValues, QueryId::EditIndividual, id);
    keyValues["display_name"] = displayName;
    SET_KEY_VALUE_ID;

    return keyValues;
}


void IlmHelper::editLocation(QObject* caller, qint64 id, QString const& city)
{
    LOGGER(id << city);

    QString query = QString("UPDATE locations SET city=? WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::EditLocation, QVariantList() << city);
}


void IlmHelper::fetchAllIndividuals(QObject* caller, bool companionsOnly, QVariant const& knownLocations)
{
    LOGGER(companionsOnly << knownLocations);

    QString query = QString("SELECT i.id,%1 AS display_name,hidden,is_companion,female FROM individuals i").arg( NAME_FIELD("i") );
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
    m_sql->executeQuery(caller, QString("SELECT mentions.id,%1 AS target,points,mentions.target AS target_id FROM mentions LEFT JOIN individuals i ON mentions.target=i.id WHERE suite_page_id=%2").arg( NAME_FIELD("i") ).arg(suitePageId), QueryId::FetchBioMetadata);
}


void IlmHelper::fetchTeachers(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS teacher,i.female FROM teachers INNER JOIN individuals i ON teachers.teacher=i.id WHERE teachers.individual=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchTeachers);
}


void IlmHelper::fetchSiblings(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id AS id,%1 AS sibling,i.female FROM siblings INNER JOIN individuals i ON siblings.sibling_id=i.id WHERE siblings.individual=%2 UNION SELECT i.id AS id,%1 AS sibling,i.female FROM siblings INNER JOIN individuals i ON siblings.individual=i.id WHERE siblings.sibling_id=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchSiblings);
}


void IlmHelper::fetchParents(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS parent,i.female FROM parents INNER JOIN individuals i ON parents.parent_id=i.id WHERE parents.individual=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchParents);
}


void IlmHelper::fetchStudents(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS student,i.female FROM teachers INNER JOIN individuals i ON teachers.individual=i.id WHERE teachers.teacher=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchStudents);
}


void IlmHelper::fetchChildren(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS child,i.female FROM parents INNER JOIN individuals i ON parents.individual=i.id WHERE parents.parent_id=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchChildren);
}


void IlmHelper::fetchFrequentIndividuals(QObject* caller, QString const& table, QString const& field, int n)
{
    m_sql->executeQuery(caller, QString("SELECT %4 AS id,%2 AS display_name,is_companion,female FROM (SELECT %4,COUNT(%4) AS n FROM %3 GROUP BY %4 ORDER BY n DESC LIMIT %1) INNER JOIN individuals i ON i.id=%4 GROUP BY i.id ORDER BY display_name").arg(n).arg( NAME_FIELD("i") ).arg(table).arg(field), QueryId::FetchAllIndividuals);
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


QVariantMap IlmHelper::createIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description)
{
    LOGGER( prefix << name << kunya << displayName << birth << death << female << location << level << description );

    QVariantMap keyValues = TokenHelper::getTokensForIndividual(prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, level, description);
    qint64 id = m_sql->executeInsert("individuals", keyValues);
    keyValues["display_name"] = !displayName.isEmpty() ? displayName : name;
    SET_KEY_VALUE_ID;

    return keyValues;
}


void IlmHelper::fetchBio(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    m_sql->executeQuery(caller, QString("SELECT mentions.id,%1 AS author,heading,title,suite_page_id,suites.reference,suite_pages.reference AS suite_page_reference,points,suite_pages.suite_id FROM mentions INNER JOIN suite_pages ON mentions.suite_page_id=suite_pages.id INNER JOIN suites ON suites.id=suite_pages.suite_id LEFT JOIN individuals i ON suites.author=i.id WHERE target=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchBio);
}


void IlmHelper::lazyInit()
{
}


void IlmHelper::portIndividuals(QObject* caller, QString destinationLanguage)
{
    QString srcLanguage = databaseName();
    destinationLanguage = QURAN_TAFSIR_FILE(destinationLanguage);
    m_sql->attachIfNecessary(destinationLanguage, true);

    m_sql->startTransaction(caller, QueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("UPDATE %1.individuals SET %2,%3,%4,%5").arg(destinationLanguage)
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "prefix") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "name") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "kunya") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "hidden") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "birth") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "death") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "female") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "location") )
            .arg( FIELD_REPLACE(destinationLanguage, srcLanguage, "is_companion") ), QueryId::PendingTransaction);

    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.locations SELECT * FROM %2.locations WHERE id NOT IN (SELECT id FROM %1.locations)").arg(destinationLanguage).arg(srcLanguage), QueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.individuals SELECT * FROM %2.individuals WHERE id NOT IN (SELECT id FROM %1.individuals)").arg(destinationLanguage).arg(srcLanguage), QueryId::PendingTransaction);
    m_sql->executeQuery(caller, QString("DELETE FROM %1.individuals WHERE id NOT IN (SELECT id FROM %2.individuals)").arg(destinationLanguage).arg(srcLanguage), QueryId::PendingTransaction);
    m_sql->endTransaction(caller, QueryId::PortIndividuals);

    m_sql->detach(destinationLanguage);
}


void IlmHelper::setDatabaseName(QString const& name) {
    m_name = name;
}


QString IlmHelper::databaseName() const {
    return m_name;
}


QVariantMap IlmHelper::parseName(QString n)
{
    if ( m_prefixes.isEmpty() )
    {
        QStringList prefixes = QStringList() << "Shaykh-ul" << "ash-Shaykh" << "ash-Sheikh" << "Dr." << "Doctor" << "Shaykh" << "Sheikh" << "Shaikh" << "Imam" << "Imaam" << "Al-Imaam" << "Imâm" << "Imām" << "al-’Allaamah" << "Al-‘Allaamah" << "Al-Allaamah" << "Al-Allamah" << "Al-Allama" << "Al-Allaama" << "Allaama" << "Muhaddith" << "Al-Haafidh" << "Al-Hafith" << "Al-Hafidh" << "Al-Haafidh" << "Hafidh" << "Ustadh" << "Prince" << "King" << "al-Faqeeh" << "al-Faqih";

        foreach (QString const& p, prefixes) {
            m_prefixes << p.toLower();
        }
    }

    if ( m_kunyas.isEmpty() )
    {
        QStringList kunyas = QStringList() << "Abu" << "Aboo";

        foreach (QString const& p, kunyas) {
            m_kunyas << p.toLower();
        }
    }

    QStringList prefix;
    QStringList kunya;
    int death = 0;
    QStringList all = n.split(" ");
    QVariantMap result;

    if ( all.size() > 1 )
    {
        QString last = all.last().toLower();
        QString secondLast = all.at( all.size()-2 ).toLower();

        if ( QRegExp("[\\(\\[]{0,1}died|[\\(\\[]{0,1}d\\.{0,1}$").exactMatch(secondLast) )
        {
            last.remove( QRegExp("\\D") ); // remove all non numeric values
            death = last.toInt();

            if (death > 0)
            {
                all.takeLast();
                all.takeLast();
            }
        }
    }

    while ( !all.isEmpty() )
    {
        QString current = all.first();
        LOGGER(current);

        if ( m_prefixes.contains( current.toLower() ) ) {
            prefix << all.takeFirst();
        } else if ( m_kunyas.contains( current.toLower() ) ) {
            kunya << all.takeFirst() << all.takeFirst(); // take the abu as well as the next word

            if ( !all.isEmpty() )
            {
                QString next = all.first().toLower();

                if (next == "abdur" || next == "abdul" || next == "abdi") { // it's part of a two-word kunya
                    kunya << all.takeFirst();
                }
            }
        } else {
            break;
        }
    }

    if ( all.isEmpty() && !kunya.isEmpty() ) // if there was only a kunya
    {
        all = kunya;
        kunya.clear();
    }

    if ( !kunya.isEmpty() ) {
        result[KEY_KUNYA] = kunya.join(" ");
    }

    if ( !prefix.isEmpty() ) {
        result[KEY_PREFIX] = prefix.join(" ");
    }

    if ( !all.isEmpty() ) {
        result[KEY_NAME] = all.join(" ");
    }

    if (death > 0) {
        result[KEY_DEATH] = death;
    }

    return result;
}


IlmHelper::~IlmHelper()
{
}

} /* namespace ilm */
