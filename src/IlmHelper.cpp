#include "precompiled.h"

#include "IlmHelper.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "QueryId.h"
#include "TextUtils.h"

#define KEY_DEATH "death"
#define KEY_KUNYA "kunya"
#define KEY_NAME "name"
#define KEY_PREFIX "prefix"
#define NAME_FIELD(var) QString("coalesce(%1.displayName, TRIM((coalesce(%1.prefix,'') || ' ' || %1.name || ' ' || coalesce(%1.kunya,''))))").arg(var)
#define NAME_SEARCH(var) QString("%1.name LIKE '%' || ? || '%' OR %1.displayName LIKE '%' || ? || '%' OR %1.kunya LIKE '%' || ? || '%'").arg(var)

namespace ilm {

using namespace admin;

IlmHelper::IlmHelper(DatabaseHelper* sql) : m_sql(sql)
{
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


void IlmHelper::removeQuote(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM quotes WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveQuote);
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


void IlmHelper::removeTafsir(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("DELETE FROM suites WHERE id=%1").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTafsir);
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


void IlmHelper::removeTafsirPage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("DELETE FROM suite_pages WHERE id=%1").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTafsirPage);
}


void IlmHelper::replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId)
{
    LOGGER(toReplaceId << actualId);

    m_sql->startTransaction(caller, QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE mentions SET target=%1 WHERE target=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE quotes SET author=%1 WHERE author=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE suites SET author=%1 WHERE author=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE suites SET translator=%1 WHERE translator=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE suites SET explainer=%1 WHERE explainer=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE teachers SET teacher=%1 WHERE teacher=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE teachers SET individual=%1 WHERE individual=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE parents SET parent_id=%1 WHERE teacparent_idher=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE parents SET individual=%1 WHERE individual=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE siblings SET sibling_id=%1 WHERE sibling_id=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE siblings SET individual=%1 WHERE individual=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("UPDATE websites SET individual=%1 WHERE individual=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->executeQuery(caller, QString("DELETE FROM individuals WHERE id=%1").arg(toReplaceId), QueryId::ReplacingIndividual);
    m_sql->endTransaction(caller, QueryId::ReplaceIndividual);
}


void IlmHelper::mergeSuites(QObject* caller, QVariantList const& toReplaceIds, qint64 actualId)
{
    LOGGER(toReplaceIds << actualId);

    m_sql->startTransaction(caller, QueryId::ReplacingSuite);

    foreach (QVariant const& q, toReplaceIds)
    {
        qint64 toReplaceId = q.toLongLong();

        m_sql->executeQuery(caller, QString("UPDATE suite_pages SET suite_id=%1,heading=(SELECT title FROM suites WHERE id=%2),reference=(SELECT reference FROM suites WHERE id=%2) WHERE suite_id=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingSuite);
        m_sql->executeQuery(caller, QString("UPDATE quotes SET suite_id=%1 WHERE suite_id=%2").arg(actualId).arg(toReplaceId), QueryId::ReplacingSuite);
        m_sql->executeQuery(caller, QString("DELETE FROM suites WHERE id=%1").arg(toReplaceId), QueryId::ReplacingSuite);
    }

    m_sql->endTransaction(caller, QueryId::ReplaceSuite);
}


void IlmHelper::searchIndividuals(QObject* caller, QString const& trimmedText)
{
    LOGGER(trimmedText);
    m_sql->executeQuery(caller, QString("SELECT id,%2 AS name,is_companion,hidden FROM individuals i WHERE %1 ORDER BY displayName,name").arg( NAME_SEARCH("i") ).arg( NAME_FIELD("i") ), QueryId::SearchIndividuals, QVariantList() << trimmedText << trimmedText << trimmedText);
}


void IlmHelper::searchQuote(QObject* caller, QString fieldName, QString const& searchTerm)
{
    LOGGER(fieldName << searchTerm);

    QString query;
    QVariantList args = QVariantList() << searchTerm;

    if (fieldName == "author") {
        query = QString("SELECT quotes.id,%1 AS author,body,reference FROM quotes INNER JOIN individuals i ON i.id=quotes.author WHERE %2 ORDER BY quotes.id DESC").arg( NAME_FIELD("i") ).arg( NAME_SEARCH("i") );
        args << searchTerm << searchTerm;
    } else {
        query = QString("SELECT quotes.id,%2 AS author,body,reference FROM quotes INNER JOIN individuals i ON i.id=quotes.author WHERE %1 LIKE '%' || ? || '%' ORDER BY quotes.id DESC").arg(fieldName).arg( NAME_FIELD("i") );
    }

    m_sql->executeQuery(caller, query, QueryId::SearchQuote, args);
}


void IlmHelper::searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm)
{
    LOGGER(fieldName << searchTerm);

    QString query;
    QVariantList args = QVariantList() << searchTerm;

    if (fieldName == "author" || fieldName == "explainer" || fieldName == "translator")
    {
        if (fieldName == "author") {
            query = QString("SELECT suites.id,%1 AS author,title FROM suites LEFT JOIN individuals i ON i.id=suites.author WHERE %2 ORDER BY suites.id DESC").arg( NAME_FIELD("i") ).arg( NAME_SEARCH("i") );
            args << searchTerm << searchTerm;
        } else {
            query = QString("SELECT suites.id,%2 AS author,title FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN individuals t ON t.id=suites.%1 WHERE %3 ORDER BY suites.id DESC").arg(fieldName).arg( NAME_FIELD("i") ).arg( NAME_SEARCH("i") );
            args << searchTerm << searchTerm;
        }
    } else if (fieldName == "body") {
        query = QString("SELECT suites.id,%1 AS author,title FROM suites LEFT JOIN individuals i ON i.id=suites.author INNER JOIN suite_pages ON suites.id=suite_pages.suite_id WHERE body LIKE '%' || ? || '%' ORDER BY suites.id DESC").arg( NAME_FIELD("i") );
    } else {
        query = QString("SELECT suites.id,%2 AS author,title FROM suites LEFT JOIN individuals i ON i.id=suites.author WHERE %1 LIKE '%' || ? || '%' ORDER BY suites.id DESC").arg(fieldName).arg( NAME_FIELD("i") );
    }

    m_sql->executeQuery(caller, query, QueryId::SearchTafsir, args);
}


qint64 IlmHelper::addBioLink(QObject* caller, qint64 suitePageId, qint64 targetId, QVariant const& points)
{
    LOGGER(suitePageId << targetId << points);

    qint64 id = QDateTime::currentMSecsSinceEpoch();

    QString query = "INSERT INTO mentions (id,target,suite_page_id,points) VALUES(?,?,?,?)";
    m_sql->executeQuery(caller, query, QueryId::AddBioLink, QVariantList() << id << targetId << suitePageId << points);

    return id;
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


void IlmHelper::addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference, QString const& suiteId, QString const& uri)
{
    LOGGER(author << body << reference << suiteId << uri);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("INSERT INTO quotes (author,body,reference,suite_id,uri) VALUES(%1,?,?,?,?)").arg(authorId);
    QVariantList args = QVariantList() << body << reference;
    args <<  suiteId.toLongLong();
    args << uri;

    m_sql->executeQuery(caller, query, QueryId::AddQuote, args);
}


void IlmHelper::addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(author << translator << explainer << title << description << reference);

    QStringList fields = QStringList() << "id" << "title" << "description" << "reference";
    QVariantList args = QVariantList() << QDateTime::currentMSecsSinceEpoch() << title << description << reference;

    if ( !author.isEmpty() )
    {
        fields << "author";
        args << generateIndividualField(caller, author);
    }

    if ( !translator.isEmpty() )
    {
        fields << "translator";
        args << generateIndividualField(caller, translator);
    }

    if ( !explainer.isEmpty() )
    {
        fields << "explainer";
        args << generateIndividualField(caller, explainer);
    }

    QString query = QString("INSERT OR IGNORE INTO suites (%1) VALUES(%2)").arg( fields.join(",") ).arg( TextUtils::getPlaceHolders( args.size(), false ) );
    m_sql->executeQuery(caller, query, QueryId::AddTafsir, args);
}


void IlmHelper::addTafsirPage(QObject* caller, qint64 suiteId, QString const& body, QString const& heading, QString const& reference)
{
    LOGGER( suiteId << body.length() << reference.length() );

    QString query = QString("INSERT OR IGNORE INTO suite_pages (id,suite_id,body,heading,reference) VALUES(%1,%2,?,?,?)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::AddTafsirPage, QVariantList() << body << heading << reference );
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


void IlmHelper::editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(suiteId << author << translator << explainer << title << description << reference);

    QStringList fields = QStringList() << "author=?" << "title=?" << "description=?" << "reference=?" << "translator=?" << "explainer=?";
    QVariantList args = QVariantList() << generateIndividualField(caller, author);
    args << title;
    args << description;
    args << reference;

    if ( translator.isEmpty() ) {
        args << QVariant();
    } else {
        args << generateIndividualField(caller, translator);
    }

    if ( explainer.isEmpty() ) {
        args << QVariant();
    } else {
        args << generateIndividualField(caller, explainer);
    }

    QString query = QString("UPDATE suites SET %2 WHERE id=%1").arg(suiteId).arg( fields.join(",") );
    m_sql->executeQuery(caller, query, QueryId::EditTafsir, args);
}


void IlmHelper::editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body, QString const& heading, QString const& reference)
{
    LOGGER( suitePageId << body.length() << heading.length() << reference.length() );

    QString query = QString("UPDATE suite_pages SET body=?, heading=?, reference=? WHERE id=%1").arg(suitePageId);
    m_sql->executeQuery( caller, query, QueryId::EditTafsirPage, QVariantList() << body << heading << reference );
}


void IlmHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, bool companion)
{
    LOGGER( id << prefix << name << kunya << displayName << hidden << birth << death << female << location );

    QString query = QString("UPDATE individuals SET prefix=?, name=?, kunya=?, displayName=?, hidden=?, birth=?, death=?, female=?, location=?, is_companion=? WHERE id=%1").arg(id);

    QVariantList args;
    args << prefix;
    args << name;
    args << kunya;
    args << displayName;
    args << ( hidden ? 1 : QVariant() );
    args << birth;
    args << death;
    args << ( female ? 1 : QVariant() );
    args << location.toLongLong();
    args << ( companion ? 1 : QVariant() );

    m_sql->executeQuery(caller, query, QueryId::EditIndividual, args);
}


void IlmHelper::editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference, QString const& suiteId, QString const& uri)
{
    LOGGER(quoteId << author << body << reference << suiteId << uri);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("UPDATE quotes SET author=%2,body=?,reference=?,suite_id=?,uri=? WHERE id=%1").arg(quoteId).arg(authorId);
    QVariantList args = QVariantList() << body << reference;
    args << suiteId.toLongLong();
    args << uri;

    m_sql->executeQuery(caller, query, QueryId::EditQuote, args);
}


void IlmHelper::editLocation(QObject* caller, qint64 id, QString const& city)
{
    LOGGER(id << city);

    QString query = QString("UPDATE locations SET city=? WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::EditLocation, QVariantList() << city);
}


void IlmHelper::fetchAllIndividuals(QObject* caller, bool companionsOnly, bool orderByDeath)
{
    QString query = "SELECT i.id,%1 AS name,hidden,is_companion FROM individuals i ORDER BY displayName,name";
    QStringList tokens;

    if (orderByDeath) {
        tokens << "death";
    }

    tokens << "displayName" << "name";

    if (companionsOnly) {
        query += " WHERE is_companion=1";
    }

    m_sql->executeQuery(caller, query.arg( NAME_FIELD("i") ), QueryId::FetchAllIndividuals);
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
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS teacher FROM teachers INNER JOIN individuals i ON teachers.teacher=i.id WHERE teachers.individual=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchTeachers);
}


void IlmHelper::fetchSiblings(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id AS id,%1 AS sibling FROM siblings INNER JOIN individuals i ON siblings.sibling_id=i.id WHERE siblings.individual=%2 UNION SELECT i.id AS id,%1 AS sibling FROM siblings INNER JOIN individuals i ON siblings.individual=i.id WHERE siblings.sibling_id=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchSiblings);
}


void IlmHelper::fetchParents(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS parent FROM parents INNER JOIN individuals i ON parents.parent_id=i.id WHERE parents.individual=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchParents);
}


void IlmHelper::fetchStudents(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS student FROM teachers INNER JOIN individuals i ON teachers.individual=i.id WHERE teachers.teacher=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchStudents);
}


void IlmHelper::fetchChildren(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS child FROM parents INNER JOIN individuals i ON parents.individual=i.id WHERE parents.parent_id=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchChildren);
}


void IlmHelper::fetchFrequentIndividuals(QObject* caller, QString const& table, QString const& field, int n)
{
    m_sql->executeQuery(caller, QString("SELECT %4 AS id,%2 AS name,is_companion FROM (SELECT %4,COUNT(%4) AS n FROM %3 GROUP BY %4 ORDER BY n DESC LIMIT %1) INNER JOIN individuals i ON i.id=%4 GROUP BY i.id ORDER BY name").arg(n).arg( NAME_FIELD("i") ).arg(table).arg(field), QueryId::FetchAllIndividuals);
}


void IlmHelper::fetchAllWebsites(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT id,uri FROM websites WHERE individual=%1 ORDER BY uri").arg(individualId), QueryId::FetchAllWebsites);
}


void IlmHelper::fetchAllTafsir(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QStringList queryParams = QStringList() << QString("SELECT suites.id AS id,%1 AS author,title FROM suites LEFT JOIN individuals i ON i.id=suites.author").arg( NAME_FIELD("i") );

    if (individualId) {
        queryParams << QString("WHERE (author=%1 OR translator=%1 OR explainer=%1)").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql->executeQuery(caller, queryParams.join(" "), QueryId::FetchAllTafsir);
}


void IlmHelper::findDuplicateSuites(QObject* caller, QString const& field)
{
    LOGGER(field);

    QString query = QString("SELECT suites.id AS id,%1 AS author,title,COUNT(*) c FROM suites LEFT JOIN individuals i ON i.id=suites.author GROUP BY %2 HAVING c > 1").arg( NAME_FIELD("i") ).arg(field);
    m_sql->executeQuery(caller, query, QueryId::FindDuplicates);
}


void IlmHelper::fetchTafsirMetadata(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("SELECT author,translator,explainer,title,description,reference FROM suites WHERE id=%1").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::FetchTafsirHeader);
}


void IlmHelper::fetchIndividualData(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QString query = QString("SELECT * FROM individuals WHERE id=%1").arg(individualId);
    m_sql->executeQuery(caller, query, QueryId::FetchIndividualData);
}


qint64 IlmHelper::createIndividual(QObject* caller, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, bool companion)
{
    LOGGER( prefix << name << kunya << displayName << birth << death << female << location << companion );

    QMap<QString,QVariant> keyValues;
    qint64 id = QDateTime::currentMSecsSinceEpoch();
    keyValues["id"] = id;
    keyValues["prefix"] = prefix;
    keyValues["name"] = name;
    keyValues["kunya"] = kunya;
    keyValues["displayName"] = displayName;
    keyValues["hidden"] = ( hidden ? 1 : QVariant() );
    keyValues["birth"] = birth;
    keyValues["death"] = death;
    keyValues["female"] = ( female ? 1 : QVariant() );
    keyValues["location"] = location.toLongLong();
    keyValues["is_companion"] = ( companion ? 1 : QVariant() );

    QString query = QString("INSERT INTO individuals (%1) VALUES (%2)").arg( QStringList( keyValues.keys() ).join(",") ).arg( TextUtils::getPlaceHolders( keyValues.size(), false ) );

    m_sql->executeQuery( caller, query, QueryId::AddIndividual, keyValues.values() );

    return id;
}


void IlmHelper::fetchTafsirContent(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    QString query = QString("SELECT %2 AS author,x.id AS author_id,x.hidden AS author_hidden,x.birth AS author_birth,x.death AS author_death,%3 AS translator,y.id AS translator_id,y.hidden AS translator_hidden,y.birth AS translator_birth,y.death AS translator_death,%4 AS explainer,z.id AS explainer_id,z.hidden AS explainer_hidden,z.birth AS explainer_birth,z.death AS explainer_death,title,description,suites.reference AS reference,suite_pages.reference AS suite_pages_reference,body,heading FROM suites INNER JOIN suite_pages ON suites.id=suite_pages.suite_id LEFT JOIN individuals x ON suites.author=x.id LEFT JOIN individuals y ON suites.translator=y.id LEFT JOIN individuals z ON suites.explainer=z.id WHERE suite_pages.id=%1").arg(suitePageId).arg( NAME_FIELD("x") ).arg( NAME_FIELD("y") ).arg( NAME_FIELD("z") );

    m_sql->executeQuery(caller, query, QueryId::FetchTafsirContent);
}


void IlmHelper::fetchBio(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    m_sql->executeQuery(caller, QString("SELECT mentions.id,%1 AS author,heading,title,suite_page_id,suites.reference,suite_pages.reference AS suite_page_reference,points FROM mentions INNER JOIN suite_pages ON mentions.suite_page_id=suite_pages.id INNER JOIN suites ON suites.id=suite_pages.suite_id LEFT JOIN individuals i ON suites.author=i.id WHERE target=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchBio);
}

void IlmHelper::fetchAllQuotes(QObject* caller, qint64 individualId)
{
    LOGGER(individualId << m_name);

    QStringList queryParams = QStringList() << QString("SELECT quotes.id AS id,%1 AS author,body,reference FROM %2.quotes INNER JOIN individuals i ON i.id=quotes.author").arg( NAME_FIELD("i") ).arg(m_name);

    if (individualId) {
        queryParams << QString("WHERE quotes.author=%1").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql->executeQuery(caller, queryParams.join(" "), QueryId::FetchAllQuotes);
}


void IlmHelper::findDuplicateQuotes(QObject* caller, QString const& field)
{
    LOGGER(field);

    QString query = QString("SELECT quotes.id AS id,%1 AS author,body,reference,COUNT(*) c FROM quotes INNER JOIN individuals i ON i.id=quotes.author GROUP BY %2 HAVING c > 1").arg( NAME_FIELD("i") ).arg(field);
    m_sql->executeQuery(caller, query, QueryId::FindDuplicates);
}


void IlmHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("SELECT id,body,heading,reference FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}


void IlmHelper::fetchQuote(QObject* caller, qint64 id)
{
    LOGGER(id);

    QString query = QString("SELECT quotes.author AS author_id, body,reference,suite_id,uri FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE quotes.id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::FetchQuote);
}


void IlmHelper::lazyInit()
{
}


void IlmHelper::translateQuote(QObject* caller, qint64 quoteId, QString destinationLanguage)
{
    LOGGER(quoteId << destinationLanguage);

    destinationLanguage = QString("quran_tafsir_%1").arg(destinationLanguage);
    m_sql->attachIfNecessary(destinationLanguage, true);

    m_sql->startTransaction(caller, QueryId::TranslatingQuote);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.quotes SELECT * FROM quotes WHERE id=%2").arg(destinationLanguage).arg(quoteId), QueryId::TranslatingQuote);
    m_sql->endTransaction(caller, QueryId::TranslateQuote);

    m_sql->detach(destinationLanguage);
}


void IlmHelper::translateSuitePage(QObject* caller, qint64 suitePageId, QString destinationLanguage)
{
    LOGGER(suitePageId << destinationLanguage);

    destinationLanguage = QString("quran_tafsir_%1").arg(destinationLanguage);
    m_sql->attachIfNecessary(destinationLanguage, true);

    m_sql->startTransaction(caller, QueryId::TranslatingSuitePage);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.suites(id,author,explainer,title,description,reference) SELECT id,author,explainer,title,description,reference FROM suites WHERE id=(SELECT suite_id FROM suite_pages WHERE id=%2)").arg(destinationLanguage).arg(suitePageId), QueryId::TranslatingSuitePage); // don't port the translator
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.suite_pages(id,suite_id,body) SELECT id,suite_id,body FROM suite_pages WHERE id=%2").arg(destinationLanguage).arg(suitePageId), QueryId::TranslatingSuitePage);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.mentions SELECT * FROM mentions WHERE suite_page_id=%2").arg(destinationLanguage).arg(suitePageId), QueryId::TranslatingSuitePage);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.explanations(surah_id,from_verse_number,to_verse_number,suite_page_id) SELECT surah_id,from_verse_number,to_verse_number,suite_page_id FROM explanations WHERE suite_page_id=%2").arg(destinationLanguage).arg(suitePageId), QueryId::TranslatingSuitePage);
    m_sql->endTransaction(caller, QueryId::TranslateSuitePage);

    m_sql->detach(destinationLanguage);
}


void IlmHelper::portIndividuals(QObject* caller, QString destinationLanguage)
{
    destinationLanguage = QString("quran_tafsir_%1").arg(destinationLanguage);
    m_sql->attachIfNecessary(destinationLanguage, true);

    m_sql->startTransaction(caller, QueryId::PortingIndividuals);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.locations SELECT * FROM locations WHERE id NOT IN (SELECT id FROM %1.locations)").arg(destinationLanguage), QueryId::PortingIndividuals);
    m_sql->executeQuery(caller, QString("INSERT OR IGNORE INTO %1.individuals SELECT * FROM individuals WHERE id NOT IN (SELECT id FROM %1.individuals)").arg(destinationLanguage), QueryId::PortingIndividuals);
    m_sql->endTransaction(caller, QueryId::PortIndividuals);

    m_sql->detach(destinationLanguage);
}


void IlmHelper::setDatabaseName(QString const& name)
{
    m_name = name;
}


QString IlmHelper::databaseName() const {
    return m_name;
}


QVariantMap IlmHelper::parseName(QString n)
{
    if ( m_prefixes.isEmpty() ) {
        m_prefixes << "Shaykh-ul" << "ash-Shaykh" << "Dr." << "Doctor" << "Shaykh" << "Sheikh" << "Shaikh" << "Imam" << "Imaam" << "Al-Imaam" << "Imâm" << "Imām" << "al-’Allaamah" << "Al-‘Allaamah" << "Allaama" << "Muhaddith" << "Al-Haafidh" << "Al-Hafith" << "Al-Hafidh" << "Al-Haafidh" << "Hafidh" << "Ustadh" << "Prince" << "King";
    }

    if ( m_kunyas.isEmpty() ) {
        m_kunyas << "Abu" << "Aboo";
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

        if ( m_prefixes.contains(current) ) {
            prefix << all.takeFirst();
        } else if ( m_kunyas.contains(current) ) {
            kunya << all.takeFirst() << all.takeFirst(); // take the abu as well as the next word

            QString next = all.first().toLower();
            if (next == "abdur" || next == "abdul" || next == "abdi") { // it's part of a two-word kunya
                kunya << all.takeFirst();
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
