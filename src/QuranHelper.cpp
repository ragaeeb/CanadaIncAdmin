#include "precompiled.h"

#include "QuranHelper.h"
#include "CommonConstants.h"
#include "DatabaseHelper.h"
#include "Logger.h"
#include "TextUtils.h"

#define CHAPTER_KEY "chapter"
#define FROM_VERSE_KEY "fromVerse"
#define TO_VERSE_KEY "toVerse"

namespace {

void analyzeVerse(QStringList tokens, int chapter, QVariantList& result)
{
    tokens = tokens.last().trimmed().split("-");
    int fromVerse = tokens.first().trimmed().toInt();
    int toVerse = tokens.last().trimmed().toInt();

    if (chapter >= 1 && chapter <= 114 && fromVerse >= 1 && fromVerse <= 286 && toVerse >= fromVerse)
    {
        QVariantMap q;
        q[CHAPTER_KEY] = chapter;
        q[FROM_VERSE_KEY] = fromVerse;
        q[TO_VERSE_KEY] = toVerse;
        result << q;
    }
}

void analyzeAyats(QRegExp const& regex, QVariantList& result, QString const& body)
{
    int pos = 0;
    while ( (pos = regex.indexIn(body, pos) ) != -1)
    {
        QString current = regex.capturedTexts().first();
        current.remove(")");
        current.remove("(");
        current.remove(" ");
        QStringList tokens = current.split(":");

        int chapter = tokens.first().trimmed().toInt();

        analyzeVerse(tokens, chapter, result);;

        pos += regex.matchedLength();
    }
}

QVariantList captureAyatsInBody(QString body, QStringList const& chapters)
{
    body.remove( QChar(8217) ); // remove special apostrophe character
    body = body.simplified();

    QVariantList result;
    analyzeAyats( QRegExp("[0-9]{1,3}:[0-9]{1,3}\\s{0,1}-\\s{0,1}[0-9]{1,3}[\\)\\]]|[0-9]{1,3}:[0-9]{1,3}[\\)\\]]|\\([0-9]{1,3}\\) {0,1}: {0,1}[0-9]{1,3}- {0,1}[0-9]{1,3}|\\([0-9]{1,3}\\) {0,1}: {0,1}[0-9]{1,3}"), result, body );

    QRegExp nameRegex = QRegExp("[A-Za-z\\-']+\\s{0,1}:\\s{0,1}[0-9]{1,3}\\s{0,1}-\\s{0,1}[0-9]{1,3}[\\)\\]]|[A-Za-z\\-']+\\s{0,1}:\\s{0,1}[0-9]{1,3}[\\)\\]]");
    int pos = 0;

    while ( (pos = nameRegex.indexIn(body, pos) ) != -1)
    {
        QString current = nameRegex.capturedTexts().first();
        LOGGER(current);
        current.chop(1);
        QStringList tokens = current.split(":");

        QString chapterName = tokens.first().trimmed();
        int chapter = 0;

        for (int i = chapters.size()-1; i >= 0; i--)
        {
            if ( canadainc::TextUtils::isSimilar(chapters[i], chapterName, 70) )
            {
                chapter = i+1;
                break;
            }
        }

        if (chapter) {
            analyzeVerse(tokens, chapter, result);
        }

        pos += nameRegex.matchedLength();
    }

    return result;
}

QStringList fetchChapters()
{
    QStringList result;

    bb::data::XmlDataAccess xda;
    QVariantList list = xda.load("app/native/assets/xml/quran-data.xml", "sura").toList();

    foreach (QVariant const& q, list) {
        result << q.toMap().value("tname").toString();
    }

    return result;
}

}

namespace quran {

using namespace admin;
using namespace canadainc;
using namespace bb::data;

QuranHelper::QuranHelper(DatabaseHelper* sql) : m_sql(sql)
{
}


void QuranHelper::captureAyats(QString const& body)
{
    LOGGER( body.size() );

    QFutureWatcher<QVariantList>* qfw = new QFutureWatcher<QVariantList>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onCaptureCompleted() ) );

    QFuture<QVariantList> future = QtConcurrent::run(captureAyatsInBody, body, m_chapters);
    qfw->setFuture(future);
}


void QuranHelper::fetchAyatsForTafsir(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("SELECT id,surah_id,from_verse_number,to_verse_number FROM explanations WHERE suite_page_id=%1 ORDER BY surah_id,from_verse_number,to_verse_number").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::FetchAyatsForTafsir);
}


void QuranHelper::lazyInit()
{
    connect( &m_chaptersWatcher, SIGNAL( finished() ), this, SLOT( onChaptersFetched() ) );

    QFuture<QStringList> future = QtConcurrent::run(&fetchChapters);
    m_chaptersWatcher.setFuture(future);
}


void QuranHelper::linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse, QueryId::Type linkId)
{
    LOGGER(suitePageId << chapter << fromVerse << toVerse);
    QString query;

    if (chapter > 0)
    {
        if (fromVerse == 0) {
            query = QString("INSERT OR REPLACE INTO explanations (surah_id,suite_page_id) VALUES(%1,%2)").arg(chapter).arg(suitePageId);
        } else {
            query = QString("INSERT OR REPLACE INTO explanations (surah_id,from_verse_number,to_verse_number,suite_page_id) VALUES(%1,%2,%3,%4)").arg(chapter).arg(fromVerse).arg(toVerse).arg(suitePageId);
        }

        m_sql->executeQuery(caller, query, linkId);
    }
}


void QuranHelper::linkAyatsToTafsir(QObject* caller, qint64 suitePageId, QVariantList const& chapterVerseData)
{
    m_sql->startTransaction(caller, QueryId::LinkingAyatsToTafsir);

    foreach (QVariant const& q, chapterVerseData)
    {
        QVariantMap qvm = q.toMap();
        linkAyatToTafsir( caller, suitePageId, qvm.value(CHAPTER_KEY).toInt(), qvm.value(FROM_VERSE_KEY).toInt(), qvm.value(TO_VERSE_KEY).toInt() );
    }

    m_sql->endTransaction(caller, QueryId::LinkAyatsToTafsir);
}


void QuranHelper::onCaptureCompleted()
{
    QFutureWatcher<QVariantList>* qfw = static_cast< QFutureWatcher<QVariantList>* >( sender() );
    QVariantList result = qfw->result();
    LOGGER( result.size() );

    sender()->deleteLater();

    emit ayatsCaptured(result);
}


void QuranHelper::onChaptersFetched()
{
    m_chapters = m_chaptersWatcher.result();

    LOGGER( m_chapters.size() );
}


void QuranHelper::unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId)
{
    LOGGER(ids << suitePageId);

    QStringList arabicIds;

    foreach (QVariant const& entry, ids) {
        arabicIds << QString::number( entry.toInt() );
    }

    QString query = QString("DELETE FROM explanations WHERE id IN (%1) AND suite_page_id=%2").arg( arabicIds.join(",") ).arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::UnlinkAyatsFromTafsir);
}


void QuranHelper::updateTafsirLink(QObject* caller, qint64 explanationId, int surahId, int fromVerse, int toVerse)
{
    LOGGER(explanationId << surahId << fromVerse << toVerse);

    QString query = QString("UPDATE explanations SET surah_id=%2,from_verse_number=%3,to_verse_number=%4 WHERE id=%1").arg(explanationId).arg(surahId).arg(fromVerse).arg(toVerse);
    m_sql->executeQuery(caller, query, QueryId::UpdateTafsirLink);
}


void QuranHelper::setDatabaseName(QString const& name)
{
    m_name = name;
}


QStringList QuranHelper::chapters() const {
    return m_chapters;
}


QuranHelper::~QuranHelper()
{
}

} /* namespace oct10 */
