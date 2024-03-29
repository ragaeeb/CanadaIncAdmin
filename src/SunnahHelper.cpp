#include "precompiled.h"

#include "SunnahHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "SharedConstants.h"
#include "TextUtils.h"

#define LIKE_CLAUSE(field) QString("(%1 LIKE '%' || ? || '%')").arg(field)
#define NARRATION_COLUMNS "narrations.id AS narration_id,collection_id,hadith_num_ar AS hadith_number,body,name"
#define TURBO_CLAUSE(collectionId, hadithNumber) QString("(collection_id=%1 AND (hadith_num_ar='%2' OR hadith_num_en='%2' OR hadith_num_ar LIKE '%2 %' OR hadith_num_en LIKE '%2 %'))").arg(collectionId).arg(hadithNumber)

namespace sunnah {

using namespace admin;
using namespace canadainc;
using namespace bb::data;

SunnahHelper::SunnahHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


void SunnahHelper::lazyInit()
{
    m_sql->attachIfNecessary("sunnah10");
}


void SunnahHelper::addTypos(QStringList const& queries, qint64 id, QString const& table)
{
    LOGGER(queries << id << table);
    m_sql->startTransaction(NULL, QueryId::Pending);

    QSet<QString> narrowed = QSet<QString>::fromList(queries);

    foreach (QString const& query, narrowed) {
        m_sql->executeQuery(NULL, QString("INSERT INTO typos(table_name,query,primary_key) VALUES (?,?,?)"), QueryId::Pending, QVariantList() << table << query << id);
    }

    m_sql->endTransaction(NULL, QueryId::AddTypos);
}


void SunnahHelper::fetchAllCollections(QObject* caller, QString const& query)
{
    QStringList terms = QStringList() << "SELECT * FROM collections";
    QVariantList params;

    if ( !query.isEmpty() ) {
        terms << QString("WHERE %1").arg( LIKE_CLAUSE("name") );
        params << query;
    }

    terms << "ORDER BY name";

    m_sql->executeQuery(caller, terms.join(" "), QueryId::FetchAllCollections, params);
}


void SunnahHelper::fetchExplanationsFor(QObject* caller, qint64 narrationId)
{
    LOGGER(narrationId);
    m_sql->executeQuery(caller, QString("SELECT suite_page_id AS id,IFNULL(i.displayName,i.name) AS author,title,substr(body,-5) AS body,heading FROM narration_explanations INNER JOIN suite_pages ON suite_pages.id=narration_explanations.suite_page_id INNER JOIN suites ON suites.id=suite_pages.suite_id INNER JOIN individuals i ON i.id=suites.author WHERE narration_explanations.narration_id IN (SELECT narration_id FROM grouped_narrations WHERE group_number=(SELECT group_number FROM grouped_narrations WHERE narration_id=%1) AND narration_id <> %1) ORDER BY author,title,heading").arg(narrationId), QueryId::FetchExplanationsFor);
}


void SunnahHelper::fetchNarration(QObject* caller, QVariantList const& terms)
{
    LOGGER(terms);

    QStringList clauses;

    foreach (QVariant const& q, terms)
    {
        QVariantMap qvm = q.toMap();
        qint64 collectionId = qvm.value("collection_id").toLongLong();
        QString hadithNumber = qvm.value("hadith_number").toString();
        clauses << TURBO_CLAUSE(collectionId, hadithNumber);
    }

    QString query = QString("SELECT %1,grouped_narrations.group_number AS group_id FROM narrations INNER JOIN collections ON collection_id=collections.id LEFT JOIN grouped_narrations ON narrations.id=grouped_narrations.narration_id WHERE %2 ORDER BY narration_id").arg(NARRATION_COLUMNS).arg( clauses.join(" OR ") );

    m_sql->executeQuery(caller, query, QueryId::SearchNarrations);
}


void SunnahHelper::fetchNarrationsInGroup(QObject* caller, int groupNumber)
{
    LOGGER(groupNumber);

    QString query = QString("SELECT %1 FROM narrations INNER JOIN collections ON collection_id=collections.id WHERE narrations.id IN (SELECT narration_id FROM grouped_narrations WHERE group_number=%2)").arg(NARRATION_COLUMNS).arg(groupNumber);
    m_sql->executeQuery(caller, query, QueryId::SearchNarrations);
}


void SunnahHelper::fetchCorrections(QObject* caller, QString const& table, QString const& query)
{
    LOGGER(query);
    m_sql->executeQuery(caller, QString("SELECT primary_key AS id FROM typos WHERE table_name=? AND query=?"), QueryId::FetchCorrections, QVariantList() << table << query);
}


void SunnahHelper::fetchGroupsForNarration(QObject* caller, qint64 narrationId)
{
    LOGGER(narrationId);
    m_sql->executeQuery(caller, QString("SELECT id,group_number FROM grouped_narrations WHERE narration_id=%1 ORDER BY group_number").arg(narrationId), QueryId::FetchGroupsForNarration);
}


void SunnahHelper::fetchNarrations(QObject* caller, QVariantList narrationIds)
{
    LOGGER(narrationIds);
    m_sql->executeQuery(caller, QString("SELECT %1 FROM narrations INNER JOIN collections ON collection_id=collections.id WHERE narrations.id IN (%2)").arg(NARRATION_COLUMNS).arg( combine(narrationIds) ), QueryId::FetchNarrations);
}


void SunnahHelper::fetchNarrationsForSuitePage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("SELECT narration_explanations.id,link_type,narration_id,hadith_num_ar AS hadith_number,collection_id,body,collections.name FROM narrations INNER JOIN narration_explanations ON narrations.id=narration_explanations.narration_id INNER JOIN collections ON collections.id=narrations.collection_id WHERE suite_page_id=%1").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::FetchNarrationsForSuitePage);
}


void SunnahHelper::fetchNextAvailableGroupNumber(QObject* caller) {
    m_sql->executeQuery(caller, "SELECT MAX(group_number)+1 AS group_number FROM grouped_narrations", QueryId::FetchNextGroupNumber);
}


void SunnahHelper::fetchGroupedNarrations(QObject* caller, QVariantList const& ids)
{
    QString query = "SELECT grouped_narrations.id,narration_id,group_number,name,body,hadith_num_ar AS hadith_number FROM grouped_narrations INNER JOIN narrations ON narrations.id=narration_id INNER JOIN collections ON collections.id=collection_id";

    if ( !ids.isEmpty() ) {
        query += QString(" WHERE narration_id IN (%1)").arg( combine(ids) );
    }

    m_sql->executeQuery(caller, query, QueryId::FetchGroupedNarrations);
}


void SunnahHelper::fetchSimilarNarrations(QObject* caller, QVariantList const& ids)
{
    LOGGER(ids);

    QString query = QString("SELECT %1 FROM narrations INNER JOIN collections ON collection_id=collections.id WHERE narrations.id IN (SELECT narration_id FROM grouped_narrations WHERE group_number=(SELECT group_number FROM grouped_narrations WHERE narration_id IN (%2))) AND narrations.id NOT IN (%2)").arg(NARRATION_COLUMNS).arg( combine(ids) );
    m_sql->executeQuery(caller, query, QueryId::SearchNarrations);
}


void SunnahHelper::searchNarrations(QObject* caller, QVariantList const& params, QVariantList const& collections, bool restrictToShort)
{
    LOGGER(params << collections);

    int n = params.size();
    QString query = QString("SELECT %1,grouped_narrations.group_number AS group_id FROM narrations INNER JOIN collections ON collection_id=collections.id LEFT JOIN grouped_narrations ON narrations.id=grouped_narrations.narration_id WHERE (%2").arg(NARRATION_COLUMNS).arg( LIKE_CLAUSE("body") );

    if (n > 1) {
        query += QString(" AND %1").arg( LIKE_CLAUSE("body") ).repeated(n-1);
    }

    query += ")";

    if ( !collections.isEmpty() )
    {
        QStringList all;

        foreach (QVariant const& q, collections) {
            all << QString::number( q.toLongLong() );
        }

        query += QString(" AND collection_id IN (%1)").arg( all.join(",") );
    }

    if (restrictToShort) {
        query += " AND length(body) < 600";
    }

    m_sql->executeQuery(caller, query, QueryId::SearchNarrations, params);
}


void SunnahHelper::groupNarrations(QObject* caller, QVariantList const& arabicIds, qint64 groupNumber)
{
    LOGGER(arabicIds << groupNumber);

    if ( groupNumber != 0 && arabicIds.size() > 1 )
    {
        QStringList selects;

        foreach (QVariant const& q, arabicIds) {
            selects << QString("SELECT %1,%2").arg( q.toInt() ).arg(groupNumber);
        }

        m_sql->executeQuery(caller, QString("INSERT OR REPLACE INTO grouped_narrations (narration_id,group_number) %1").arg( selects.join(" UNION ") ), QueryId::GroupNarrations);
    }
}


void SunnahHelper::linkNarrationsToSuitePage(QObject* caller, qint64 suitePageId, QVariantList const& arabicIds)
{
    LOGGER(suitePageId << arabicIds);

    QMap<int,bool> arabicIdMap; // used to remove duplicates

    foreach (QVariant const& current, arabicIds) {
        arabicIdMap[ current.toInt() ] = true;;
    }

    QStringList queryBlocks;
    QList<int> ids = arabicIdMap.keys();

    foreach (int arabicID, ids) {
        queryBlocks << QString("UNION SELECT %1,%2").arg(arabicID).arg(suitePageId);
    }

    queryBlocks.prepend( QString("INSERT OR REPLACE INTO narration_explanations (narration_id,suite_page_id) SELECT %1 AS 'arabicID', %2 AS 'suitePageID'").arg( arabicIds.first().toInt() ).arg(suitePageId) );
    m_sql->executeQuery( caller, queryBlocks.join(" "), QueryId::LinkNarrationsToSuitePage );
}


void SunnahHelper::reportTypo(QObject* caller, qint64 narrationId, int cursorStart, int cursorEnd)
{
    LOGGER(narrationId << cursorStart << cursorEnd);
    m_sql->executeQuery( caller, QString("INSERT INTO narration_typos (narration_id,cursor_start,cursor_end,reported_time) VALUES (%1,%2,%3,%4)").arg(narrationId).arg(cursorStart).arg(cursorEnd).arg( QDateTime::currentMSecsSinceEpoch() ), QueryId::ReportTypo );
}


void SunnahHelper::unlinkNarrationsFromSuitePage(QObject* caller, QVariantList const& arabicIds, qint64 suitePageId)
{
    LOGGER(arabicIds << suitePageId);

    QString query = QString("DELETE FROM narration_explanations WHERE narration_id IN (%1) AND suite_page_id=%2").arg( combine(arabicIds) ).arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::UnlinkNarrationsFromSuitePage);
}


void SunnahHelper::unlinkNarrationFromSimilar(QObject* caller, QVariantList const& data)
{
    LOGGER(data);
    QString query = QString("DELETE FROM grouped_narrations WHERE id IN (%1)").arg( combine(data) );
    m_sql->executeQuery(caller, query, QueryId::UnlinkNarrationsFromSimilar);
}


void SunnahHelper::updateGroupNumber(QObject* caller, QVariantList const& ids, qint64 groupNumber)
{
    LOGGER(ids << groupNumber);

    QString query = QString("UPDATE grouped_narrations SET group_number=%1 WHERE id IN (%2)").arg(groupNumber).arg( combine(ids) );
    m_sql->executeQuery(caller, query, QueryId::UpdateGroupNumbers);
}


SunnahHelper::~SunnahHelper()
{
}

} /* namespace oct10 */
