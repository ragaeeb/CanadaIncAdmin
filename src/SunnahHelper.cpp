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


void SunnahHelper::linkNarrations(QObject* caller, QVariantList const& arabicIds)
{
    LOGGER(arabicIds);
/*
    if ( arabicIds.size() > 1 )
    {
        int firstRef = 0;
        int secondRef = 0;
        QStringList queryBlocks = QueryUtils::buildLinkQueryBlocks(arabicIds, firstRef, secondRef);

        m_sql.attachIfNecessary(SIMILAR_DB, true);
        m_sql.startTransaction(NULL, QueryId::Pending);

        QStringList queryBlockChunk;

        foreach (QString const& block, queryBlocks)
        {
            queryBlockChunk << block;

            if ( queryBlockChunk.size() >= 30 )
            {
                queryBlockChunk.prepend( QString("INSERT OR IGNORE INTO similar.related (arabic_id,other_id) SELECT %1 AS 'arabicID', %2 AS 'otherID'").arg(firstRef).arg(secondRef) );
                m_sql.executeQuery( NULL, queryBlockChunk.join(" "), QueryId::Pending );
                queryBlockChunk.clear();
            }
        }

        queryBlockChunk.prepend( QString("INSERT OR IGNORE INTO similar.related (arabic_id,other_id) SELECT %1 AS 'arabicID', %2 AS 'otherID'").arg(firstRef).arg(secondRef) );
        m_sql.executeQuery( caller, queryBlockChunk.join(" "), QueryId::LinkingNarrations );
        m_sql.endTransaction(caller, QueryId::LinkNarrations);
    } */
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

    queryBlocks.prepend( QString("INSERT OR IGNORE INTO narration_explanations (narration_id,suite_page_id) SELECT %1 AS 'arabicID', %2 AS 'suitePageID'").arg( arabicIds.first().toInt() ).arg(suitePageId) );
    m_sql->executeQuery( caller, queryBlocks.join(" "), QueryId::LinkNarrationsToSuitePage );
}


void SunnahHelper::unlinkNarrationsFromSuitePage(QObject* caller, QVariantList const& arabicIds, qint64 suitePageId)
{
    LOGGER(arabicIds << suitePageId);

    QString query = QString("DELETE FROM narration_explanations WHERE narration_id IN (%1) AND suite_page_id=%2").arg( combine(arabicIds) ).arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::UnlinkNarrationsFromSuitePage);
}


void SunnahHelper::unlinkNarrationFromSimilar(QObject* caller, int arabicId)
{
    LOGGER(arabicId);
    QString query = QString("DELETE FROM related WHERE arabic_id=%1 OR other_id=%1").arg(arabicId);
    m_sql->executeQuery(caller, query, QueryId::UnlinkNarrationFromSimilar);
}


SunnahHelper::~SunnahHelper()
{
}

} /* namespace oct10 */
