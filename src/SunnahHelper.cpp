#include "precompiled.h"

#include "SunnahHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "TextUtils.h"

#define NARRATION_COLUMNS "narrations.id,collection_id,hadith_number,body,name"
#define LIKE_CLAUSE QString("(body LIKE '%' || ? || '%')")

namespace {

QString combine(QVariantList const& arabicIds)
{
    QStringList ids;

    foreach (QVariant const& entry, arabicIds) {
        ids << QString::number( entry.toInt() );
    }

    return ids.join(",");
}

}

namespace sunnah {

using namespace admin;
using namespace canadainc;
using namespace bb::data;

SunnahHelper::SunnahHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


void SunnahHelper::lazyInit()
{
    m_sql->attachIfNecessary("sunnah_english");
}


void SunnahHelper::fetchAllCollections(QObject* caller)
{
    m_sql->executeQuery(caller, "SELECT * FROM collections", QueryId::FetchAllCollections);
}


void SunnahHelper::fetchNarration(QObject* caller, qint64 collectionId, QString const& hadithNumber)
{
    LOGGER(collectionId << hadithNumber);

    QString query = QString("SELECT %1 FROM narrations INNER JOIN collections ON collections.id=narrations.collection_id WHERE collection_id=%2 AND (hadith_number='%3' OR hadith_number LIKE '%3 %')").arg(NARRATION_COLUMNS).arg(collectionId).arg(hadithNumber);
    m_sql->executeQuery(caller, query, QueryId::SearchNarrations);
}


void SunnahHelper::fetchNarrationsForSuitePage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("SELECT narration_explanations.id,link_type,narration_id,hadith_number,collection_id,body,collections.name AS collection_name FROM narrations INNER JOIN narration_explanations ON narrations.id=narration_explanations.narration_id INNER JOIN collections ON collections.id=narrations.collection_id WHERE suite_page_id=%1").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::FetchNarrationsForSuitePage);
}


void SunnahHelper::fetchNextAvailableGroupNumber(QObject* caller) {
    m_sql->executeQuery(caller, "SELECT MAX(group_number)+1 AS group_number FROM grouped_narrations", QueryId::FetchNextGroupNumber);
}


void SunnahHelper::fetchGroupedNarrations(QObject* caller, QVariantList const& ids)
{
    QString query = "SELECT grouped_narrations.id,narration_id,group_number,name,body,hadith_number FROM grouped_narrations INNER JOIN narrations ON narrations.id=narration_id INNER JOIN collections ON collections.id=collection_id";

    if ( !ids.isEmpty() ) {
        query += QString(" WHERE narration_id IN (%1)").arg( combine(ids) );
    }

    m_sql->executeQuery(caller, query, QueryId::FetchGroupedNarrations);
}


void SunnahHelper::searchNarrations(QObject* caller, QVariantList const& params, QVariantList const& collections, bool restrictToShort)
{
    LOGGER(params << collections);

    int n = params.size();
    QString query = QString("SELECT %1 FROM narrations INNER JOIN collections ON narrations.collection_id=collections.id WHERE (%2").arg(NARRATION_COLUMNS).arg(LIKE_CLAUSE);

    if ( params.size() > 1 ) {
        query += QString(" AND %1").arg(LIKE_CLAUSE).repeated(n-1);
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
        query += " AND length(body) < 500";
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
