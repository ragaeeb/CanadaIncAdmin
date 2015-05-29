#include "precompiled.h"

#include "AdminHelper.h"
#include "AppLogFetcher.h"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "Logger.h"
#include "JlCompress.h"
#include "Persistance.h"
#include "QueryHelper.h"
#include "TextUtils.h"

#define COOKIE_REPLACE_UPDATES "replace_updates"
#define TAFSIR_ZIP_DESTINATION QString("%1/plugins.zip").arg( QDir::tempPath() )
#define TAFSIR_SYNC_KEY QString("tafsir_sync_%1").arg( m_helper->translation() )

namespace {

QPair<QByteArray, QString> compressDatabase(QString const& tafsirPath)
{
    LOGGER("compressing database" << tafsirPath);

    QStringList toCompress;
    toCompress << QString("%1/%2.db").arg( QDir::homePath() ).arg(tafsirPath);

    JlCompress::compressFiles(TAFSIR_ZIP_DESTINATION, toCompress, TAFSIR_ARCHIVE_PASSWORD);

    QFile f(TAFSIR_ZIP_DESTINATION);
    f.open(QIODevice::ReadOnly);

    QByteArray qba = f.readAll();
    f.close();

    QString md5 = canadainc::IOUtils::getMd5(qba);

    LOGGER("CompressionComplete" << md5);

    return qMakePair<QByteArray, QString>(qba, md5);
}

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

QVariantList captureAyatsInBody(QString const& cookie, QString body, QMap<QString, int> const& chapterToId)
{
    body.remove( QChar(8217) ); // remove special apostrophe character
    body = body.simplified();

    QVariantList result = QVariantList() << cookie;
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

        QStringList chapters = chapterToId.keys();

        for (int i = chapters.size()-1; i >= 0; i--)
        {
            if ( canadainc::TextUtils::isSimilar(chapters[i], chapterName, 70) )
            {
                chapter = chapterToId.value(chapters[i]);
                break;
            }
        }

        analyzeVerse(tokens, chapter, result);

        pos += nameRegex.matchedLength();
    }

    return result;
}

}

namespace quran {

using namespace canadainc;
using namespace bb::cascades;

AdminHelper::AdminHelper(Persistance* persist, QueryHelper* helper) : m_persist(persist), m_helper(helper), m_lastUpdate(0)
{
}


void AdminHelper::lazyInit()
{
    disconnect( AppLogFetcher::getInstance(), SIGNAL( adminEnabledChanged() ), this, SLOT( lazyInit() ) );

    if ( AppLogFetcher::getInstance()->adminEnabled() )
    {
        connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&, bool) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&, bool) ) );
        connect( &m_network, SIGNAL( uploadProgress(QVariant const&, qint64, qint64) ), this, SIGNAL( uploadProgress(QVariant const&, qint64, qint64) ) );
        connect( m_helper->getExecutor(), SIGNAL( finished(int) ), this, SLOT( onExecuted(int) ) );
        connect( Application::instance(), SIGNAL( aboutToQuit() ), this, SLOT( onAboutToQuit() ) );
        connect( &m_watcher, SIGNAL( directoryChanged(QString const&) ), this, SLOT( onDirectoryChanged(QString const&) ) );
        connect( &m_watcher, SIGNAL( fileChanged(QString const&) ), this, SLOT( onFileChanged(QString const&) ) );

        m_lastUpdate = m_persist->getFlag(TAFSIR_SYNC_KEY).toLongLong();
        m_interested << QueryId::AddBioLink << QueryId::AddIndividual << QueryId::AddQuote << QueryId::AddTafsir << QueryId::AddTafsirPage << QueryId::EditIndividual << QueryId::EditQuote << QueryId::EditTafsir << QueryId::EditTafsirPage << QueryId::LinkAyatsToTafsir << QueryId::RemoveBioLink << QueryId::RemoveQuote << QueryId::RemoveTafsir << QueryId::RemoveTafsirPage << QueryId::UnlinkAyatsFromTafsir;
        m_helper->fetchChapters(this);

        if (m_lastUpdate) {
            emit pendingUpdatesChanged();
        }
    } else {
        connect( AppLogFetcher::getInstance(), SIGNAL( adminEnabledChanged() ), this, SLOT( lazyInit() ) );
    }
}


void AdminHelper::onDirectoryChanged(QString const& path)
{
    Q_UNUSED(path);

    if ( QFile(TAFSIR_ZIP_DESTINATION).exists() )
    {
        m_watcher.removePath( QDir::tempPath() );
        m_watcher.addPath(TAFSIR_ZIP_DESTINATION);

        m_source.setFileName( QString("%1/%2.db").arg( QDir::homePath() ).arg( m_helper->tafsirName() ) );
        m_target.setFileName(TAFSIR_ZIP_DESTINATION);
    }
}


void AdminHelper::onFileChanged(QString const& path)
{
    Q_UNUSED(path);

    emit compressProgress( m_target.size(), m_source.size()/4 ); // assume 75% compression
}


void AdminHelper::onDataLoaded(QVariant id, QVariant data)
{
    if (id.toInt() == QueryId::FetchChapters)
    {
        m_chapters.clear();

        QVariantList all = data.toList();

        foreach (QVariant q, all)
        {
            QVariantMap current = q.toMap();
            m_chapters.insert( current.value("transliteration").toString(), current.value("surah_id").toInt() );
        }
    }
}


void AdminHelper::onExecuted(int id)
{
    if ( m_interested.contains(id) )
    {
        bool isNew = m_lastUpdate == 0;
        m_lastUpdate = QDateTime::currentMSecsSinceEpoch();

        if (isNew) {
            emit pendingUpdatesChanged();
        }
    }
}


void AdminHelper::onAboutToQuit()
{
    if (m_lastUpdate) {
        m_persist->setFlag(TAFSIR_SYNC_KEY, m_lastUpdate);
    }
}


void AdminHelper::initPage(QObject* p)
{
    if ( AppLogFetcher::getInstance()->adminEnabled() )
    {
        Page* page = static_cast<Page*>(p);
        page->addAction( ActionItem::create().title( tr("Upload Local") ).imageSource( QUrl("asset:///images/menu/ic_upload_local.png") ).onTriggered( this, SLOT( uploadUpdates() ) ) );
    }
}


void AdminHelper::prepare()
{
    QFutureWatcher< QPair<QByteArray, QString> >* qfw = new QFutureWatcher< QPair<QByteArray, QString> >(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onCompressed() ) );

    QFuture< QPair<QByteArray, QString> > future = QtConcurrent::run( compressDatabase, m_helper->tafsirName() );
    qfw->setFuture(future);

    m_watcher.addPath( QDir::tempPath() );
}


void AdminHelper::uploadUpdates()
{
    LOGGER("UserEvent: UploadUpdates");

    bool yes = Persistance::showBlockingDialog( tr("Upload"), tr("This will completely replace the remote database with your local one. Are you sure you want to do this?") );
    LOGGER("UserEvent: UploadUpdatesConfirm" << yes);

    if (yes) {
        emit compressing();
        prepare();
    }
}


void AdminHelper::onCompressed()
{
    m_watcher.removePath(TAFSIR_ZIP_DESTINATION);

    QFutureWatcher< QPair<QByteArray, QString> >* qfw = static_cast< QFutureWatcher< QPair<QByteArray, QString> >* >( sender() );
    QPair<QByteArray, QString> r = qfw->result();
    QByteArray result = r.first;
    QString md5 = r.second;
    QString username = m_persist->getValueFor(KEY_ADMIN_USERNAME).toString();
    QString password = m_persist->getValueFor(KEY_ADMIN_PASSWORD).toString();
    bool validLogin = !username.isEmpty() && !password.isEmpty();
    bool success = result.size() > 0;

    LOGGER( result.size() << md5 );

    if (success)
    {
        if (validLogin)
        {
            QUrl url = CommonConstants::generateHostUrl("replace_updates.php");
            url.addQueryItem( "username", username );
            url.addQueryItem( "password", password );
            url.addQueryItem( "language", m_helper->translation() );
            url.addQueryItem( "md5", md5 );
            m_network.upload(url, "plugins.zip", result, COOKIE_REPLACE_UPDATES);
        } else {
            m_persist->showToast( tr("Authentication information missing..."), "asset:///images/menu/transfer_error.png" );
        }
    }

    qfw->deleteLater();

    emit compressed(success && validLogin);
}


void AdminHelper::onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error)
{
    QString id = cookie.toString();
    QString result = data;
    qint64 serverDbVersion = 0;
    LOGGER(id << error << result);

    qint64 now = QDateTime::currentMSecsSinceEpoch();

    if (!error)
    {
        serverDbVersion = result.toLongLong();
        error = serverDbVersion < now-(1000*60*60);

        if (serverDbVersion == -1)
        {
            m_persist->remove(KEY_ADMIN_USERNAME, false);
            m_persist->remove(KEY_ADMIN_PASSWORD, false);
            m_persist->remove(KEY_ADMIN_MODE, false);
        }
    }

    if (id == COOKIE_REPLACE_UPDATES)
    {
        if (error) {
            m_persist->showToast( tr("Update submission failed!"), ASSET_YELLOW_DELETE );
        } else {
            m_persist->showToast( tr("Successfully submitted updates!"), "asset:///images/toast/success_upload_local.png" );
            m_persist->setFlag( KEY_TAFSIR_VERSION( m_helper->translation() ), serverDbVersion );
            m_persist->setFlag(KEY_LAST_UPDATE, now);
            m_persist->setFlag( KEY_APP_DB_VERSION, QCoreApplication::applicationVersion() );
            m_persist->setFlag(TAFSIR_SYNC_KEY);
            m_lastUpdate = 0;
            emit pendingUpdatesChanged();
        }
    }
}


void AdminHelper::doDiff(QVariantList const& input, bb::cascades::ArrayDataModel* adm, QString const& key)
{
    QSet<qint64> keys;

    for (int i = adm->size()-1; i >= 0; i--) {
        keys << adm->value(i).toMap().value(key).toLongLong();
    }

    foreach (QVariant const& x, input) {
        if ( !keys.contains( x.toMap().value(key).toLongLong() ) ) {
            adm->insert(0, x);
        }
    }
}


void AdminHelper::analyzeKingFahadFrench(QString text)
{
    LOGGER( text.size() );
/*
    QMap<int,Surah> surahIdToMetadata;
    QStringList tafsirs; // all the tafsir texts for the ayats
    QMap<int,int> tafsirIdToAyat; // maps the tafsir ID to the ayat #. for example 2,3 means (2) maps to ayat #3, which means ayats[2]
    QVariantMap surahIdToData; // 1 maps to a QVariantMap, which has keys: "translation", "transliteration", "tafsir", "verses" is a QVariantList of QVariantMaps with keys: "content"

    QRegExp chapterRegex = QRegExp("^(SOURATE)\\s+\\d+");
    QRegExp ayatRegex = QRegExp("^\\d+\\.");
    QRegExp chapterReferenceRegex = QRegExp("\\(\\d+\\)$");
    QRegExp tafsirRegex = QRegExp("^\\(\\d+\\)");

    text = text.trimmed();
    QStringList lines = text.split("\n");
    lines.removeAll("\n");
    lines.removeAll("");
    int n = lines.size();

    int currentChapter = 0;
    QStringList currentAyats; // all the translated ayats, index 0 has first ayat, index 1 has second ayat, and so on...

    for (int i = 0; i < n; i++)
    {
        QString line = lines[i].trimmed();

        if ( !line.isEmpty() )
        {
            if ( chapterRegex.indexIn(line) == 0 )
            {
                QVariantMap s;
                currentChapter = line.split("\\s+").last().toInt();
                line = lines[++i].toLower();
                int spaceIndex = line.indexOf(" ");
                s["transliteration"] = TextUtils::toTitleCase( line.left(spaceIndex) );

                QString translation = line.mid(spaceIndex+1);

                if ( chapterReferenceRegex.exactMatch(translation) )
                {
                    int lastLeft = translation.lastIndexOf("(");
                    QString referenceStr = translation.mid(lastLeft+1);
                    referenceStr.chop(1); // remove the last bracket
                    tafsirIdToAyat.insert( referenceStr.toInt(), 0 ); // references the chapter itself and not any ayat

                    translation = translation.remove( lastLeft, translation.length()-lastLeft );
                }

                TextUtils::removeBrackets(translation);
                s["translation"] = translation;

                i += 2; // next line is # of verses, and next line is revelation order
                line = lines[++i];

                if ( ayatRegex.indexIn(line) != 0 ) {
                    s["tafsir"] = line;
                }

                surahIdToMetadata.insert(currentChapter, s);
            }

            if ( ayatRegex.indexIn(line) == 0 )
            {
                line.remove( 0, line.indexOf(" ")+1 );

                int verseId = currentAyats.size()+1;
                QRegExp ayatTafsirReferenceRegex = QRegExp("\\(\\d+\\)");
                int pos = 0;
                while ( (pos = ayatTafsirReferenceRegex.indexIn(line, pos) ) != -1)
                {
                    QString current = ayatTafsirReferenceRegex.capturedTexts().first();
                    int tafsirId = TextUtils::removeBrackets(current).toInt();
                    tafsirIdToAyat.insert(tafsirId, verseId);

                    pos += ayatTafsirReferenceRegex.matchedLength();
                }

                line.remove(ayatTafsirReferenceRegex);
                line.remove("  ");
                currentAyats << line.trimmed();
            }

            if ( tafsirRegex.indexIn(line) == 0 )
            {
                line.remove( 0, line.indexOf(" ")+1 );
                tafsirs << line;
            }
        }
    }

    LOGGER( "**" << tafsirIdToAyat );
    LOGGER("** ayats" << currentAyats);
    LOGGER("** tafsirs" << tafsirs); */
}


void AdminHelper::captureAyats(QString const& cookie, QString const& body)
{
    LOGGER( body.size() );

    QFutureWatcher<QVariantList>* qfw = new QFutureWatcher<QVariantList>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onCaptureCompleted() ) );

    QFuture<QVariantList> future = QtConcurrent::run(captureAyatsInBody, cookie, body, m_chapters);
    qfw->setFuture(future);
}


void AdminHelper::onCaptureCompleted()
{
    QFutureWatcher<QVariantList>* qfw = static_cast< QFutureWatcher<QVariantList>* >( sender() );
    QVariantList result = qfw->result();
    QString cookie = result.takeFirst().toString();
    LOGGER( result.size() );

    sender()->deleteLater();

    emit ayatsCaptured(result, cookie);
}


bool AdminHelper::pendingUpdates() {
    return m_lastUpdate > 0;
}


AdminHelper::~AdminHelper()
{
}

} /* namespace sunnah */
