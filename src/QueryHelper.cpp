#include "precompiled.h"

#include "QueryHelper.h"
#include "CommonConstants.h"
#include "Logger.h"
#include "QueryId.h"
#include "TextUtils.h"

#define ATTACH_TAFSIR m_sql.attachIfNecessary( tafsirName(), true );
#define TRANSLATION_NAME(language) QString("quran_%1").arg(language)
#define TRANSLATION TRANSLATION_NAME(m_translation)
#define TAFSIR_NAME(language) QString("quran_tafsir_%1").arg(language)

namespace {

bool tafsirFileExists(QString const& t)
{
    QFile q( QString("%1/%2.db").arg( QDir::homePath() ).arg(t) );
    return q.exists() && q.size() > 0;
}

QString combine(QVariantList const& arabicIds)
{
    QStringList ids;

    foreach (QVariant const& entry, arabicIds) {
        ids << QString::number( entry.toInt() );
    }

    return ids.join(",");
}

QVariant protect(QString const& a) {
    return a.isEmpty() ? QVariant() : a;
}

}

namespace quran {

using namespace canadainc;
using namespace bb::data;

QueryHelper::QueryHelper(Persistance* persist) :
        m_sql( QString("%1/assets/dbase/quran_arabic.db").arg( QCoreApplication::applicationDirPath() ) ),
        m_persist(persist), m_bookmarkHelper(&m_sql), m_tafsirHelper(&m_sql)
{
    connect( persist, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ), Qt::QueuedConnection );
}


void QueryHelper::lazyInit()
{
    m_sql.enableForeignKeys();
    refreshDatabase();
}


void QueryHelper::refreshDatabase() {
    settingChanged(KEY_TRANSLATION);
}


void QueryHelper::settingChanged(QString const& key)
{
    if (key == KEY_TRANSLATION)
    {
        if ( showTranslation() )
        {
            m_sql.detach( TRANSLATION_NAME(ENGLISH_TRANSLATION) ); // in case we had to fall back
            m_sql.detach(TRANSLATION);
        }

        m_sql.detach( tafsirName() );

        m_translation = m_persist->getValueFor(KEY_TRANSLATION).toString();

        QVariantMap params;
        QStringList forcedUpdates;

        if ( showTranslation() ) // if the user didn't set to Arabic only, since arabic is already attached
        {
            bool inHome = m_translation != ENGLISH_TRANSLATION;
            QString translationDir = inHome ? QDir::homePath() : QString("%1/assets/dbase").arg( QCoreApplication::applicationDirPath() );
            QFile translationFile( QString("%1/%2.db").arg(translationDir).arg(TRANSLATION) );

            if ( !translationFile.exists() || translationFile.size() == 0 ) { // translation doesn't exist, download it
                params[KEY_TRANSLATION] = TRANSLATION;
                forcedUpdates << KEY_TRANSLATION;
                LOGGER("Using english translation as fallback...");
                m_sql.attachIfNecessary( TRANSLATION_NAME(ENGLISH_TRANSLATION) ); // fall back to English for the time being...
            } else {
                m_sql.attachIfNecessary(TRANSLATION, inHome); // since english translation is loaded by default
            }
        }

        if ( !tafsirFileExists( tafsirName() ) ) { // tafsir doesn't exist, download it
            params[KEY_TAFSIR] = tafsirName();
            forcedUpdates << KEY_TAFSIR;

            setupTables();
        } else if ( m_persist->isUpdateNeeded(KEY_LAST_UPDATE, 60) ) {
            params[KEY_TAFSIR] = tafsirName();
            params[KEY_TRANSLATION] = TRANSLATION;
        }

        if ( !forcedUpdates.isEmpty() ) {
            params[KEY_FORCED_UPDATE] = forcedUpdates;
        }

        if ( !params.isEmpty() ) // update check needed
        {
            bool suppress = m_persist->getFlag(KEY_UPDATE_CHECK_FLAG).toInt() == SUPPRESS_UPDATE_FLAG;

            if ( params.contains(KEY_FORCED_UPDATE) || !suppress ) // if it's a forced update
            {
                params[KEY_LANGUAGE] = m_translation;
                emit updateCheckNeeded(params);
            }
        } else {
            ATTACH_TAFSIR;
        }

        emit textualChange();
    } else if (key == KEY_TRANSLATION_SIZE || key == KEY_PRIMARY_SIZE) {
        emit fontSizeChanged();
    }
}


void QueryHelper::fetchChapters(QObject* caller, QString const& text)
{
    QVariantList args;
    QString query = ThreadUtils::buildChaptersQuery( args, text, showTranslation() );
    m_sql.executeQuery(caller, query, QueryId::FetchChapters, args);
}


void QueryHelper::fetchChapter(QObject* caller, int chapter, bool juzMode)
{
    LOGGER(chapter);

    if (juzMode)
    {
        if ( showTranslation() ) {
            m_sql.executeQuery(caller, QString("SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration,j.id AS juz_id,verse_number FROM surahs a INNER JOIN chapters t ON a.id=t.id LEFT JOIN juzs j ON j.surah_id=a.id WHERE a.id=%1").arg(chapter), QueryId::FetchChapters);
        } else {
            m_sql.executeQuery(caller, QString("SELECT surahs.id AS surah_id,name,verse_count,revelation_order,j.id AS juz_id,verse_number FROM surahs LEFT JOIN juzs j ON j.surah_id=a.id WHERE id=%1").arg(chapter), QueryId::FetchChapters );
        }
    } else {
        QString query = "SELECT id AS surah_id,name,verse_count,revelation_order FROM surahs";

        if ( showTranslation() ) {
            query = "SELECT a.id AS surah_id,name,verse_count,revelation_order,transliteration FROM surahs a INNER JOIN chapters t ON a.id=t.id";
        }

        query += QString(" WHERE surah_id=%1").arg(chapter);

        m_sql.executeQuery(caller, query, QueryId::FetchChapters);
    }
}


void QueryHelper::fetchRandomAyat(QObject* caller)
{
    LOGGER("fetchRandomAyat");
    int x = TextUtils::randInt(1, 6236);

    if ( !showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number AS verse_id,content AS text FROM ayahs WHERE ROWID=%1").arg(x), QueryId::FetchRandomAyat);
    } else {
        m_sql.executeQuery(caller, QString("SELECT chapter_id AS surah_id,verse_id,translation AS text FROM verses WHERE ROWID=%1").arg(x), QueryId::FetchRandomAyat);
    }
}


void QueryHelper::fetchAdjacentAyat(QObject* caller, int surahId, int verseId, int delta)
{
    LOGGER(surahId << verseId << delta);

    QString operation = delta >= 0 ? QString("+%1").arg(delta) : QString::number(delta);
    m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number AS verse_id FROM ayahs WHERE ROWID=((SELECT ROWID FROM ayahs WHERE surah_id=%1 AND verse_number=%2)%3)").arg(surahId).arg(verseId).arg(operation), QueryId::FetchAdjacentAyat);
}


void QueryHelper::fetchRandomQuote(QObject* caller)
{
    LOGGER("fetchRandomQuote");

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT %1 AS author,i.hidden,body,TRIM( COALESCE(suites.title,'') || ' ' || COALESCE(quotes.reference,'') ) AS reference,birth,death,female,is_companion FROM quotes INNER JOIN individuals i ON i.id=quotes.author LEFT JOIN suites ON quotes.suite_id=suites.id WHERE quotes.id=( ABS( RANDOM() % (SELECT COUNT() AS total_quotes FROM quotes) )+1 )").arg( NAME_FIELD("i") ), QueryId::FetchRandomQuote);
}


void QueryHelper::fetchSurahHeader(QObject* caller, int chapterNumber)
{
    LOGGER(chapterNumber);

    if ( showTranslation() ) {
        m_sql.executeQuery( caller, QString("SELECT name,translation,transliteration FROM surahs s INNER JOIN chapters c ON s.id=c.id WHERE s.id=%1").arg(chapterNumber), QueryId::FetchSurahHeader );
    } else {
        m_sql.executeQuery( caller, QString("SELECT name FROM surahs WHERE id=%1").arg(chapterNumber), QueryId::FetchSurahHeader );
    }
}


void QueryHelper::fetchAllAyats(QObject* caller, int fromChapter, int toChapter)
{
    LOGGER(fromChapter << toChapter);

    if (toChapter == 0) {
        toChapter = fromChapter;
    }

    QString query;
    QString ayatImagePath = "";
    QVariantList params;

    if ( m_persist->getValueFor(KEY_JOIN_LETTERS).toInt() == 1 )
    {
        QDir q( QString("%1/%2").arg( m_persist->getValueFor(KEY_OUTPUT_FOLDER).toString() ).arg(JOINED_LETTERS_DIRECTORY) );

        if ( q.exists() )
        {
            ayatImagePath = QString(",? || ayahs.surah_id || '_' || ayahs.verse_number || '.png' AS imagePath");
            params << q.path()+"/";
        }
    }

    if ( showTranslation() ) {
        query = QString("SELECT ayahs.surah_id,content AS arabic,ayahs.verse_number AS verse_id,translation%3 FROM ayahs INNER JOIN verses ON (ayahs.surah_id=verses.chapter_id AND ayahs.verse_number=verses.verse_id) WHERE ayahs.surah_id BETWEEN %1 AND %2").arg(fromChapter).arg(toChapter).arg(ayatImagePath);
    } else {
        query = QString("SELECT ayahs.surah_id,content AS arabic,ayahs.verse_number AS verse_id%3 FROM ayahs WHERE ayahs.surah_id BETWEEN %1 AND %2").arg(fromChapter).arg(toChapter).arg(ayatImagePath);
    }

    m_sql.executeQuery(caller, query, QueryId::FetchAllAyats, params);
}


void QueryHelper::fetchJuzInfo(QObject* caller, int juzId)
{
    LOGGER(juzId);
    m_sql.executeQuery(caller, QString("SELECT surah_id,verse_number FROM juzs WHERE id BETWEEN %1 AND %2").arg(juzId).arg(juzId+1), QueryId::FetchJuz);
}


void QueryHelper::fetchAllTafsir(QObject* caller, qint64 individualId)
{
    ATTACH_TAFSIR;
    m_tafsirHelper.fetchAllTafsir(caller, individualId);
}


void QueryHelper::fetchTafsirCountForAyat(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT COUNT() AS tafsir_count FROM explanations WHERE surah_id=%1 AND (%2 BETWEEN from_verse_number AND to_verse_number)").arg(chapterNumber).arg(verseNumber), QueryId::FetchTafsirCountForAyat);
}


void QueryHelper::fetchAllTafsirForSuite(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    ATTACH_TAFSIR;
    QString query = QString("SELECT id,body,heading,reference FROM suite_pages WHERE suite_id=%1 ORDER BY id DESC").arg(suiteId);
    m_sql.executeQuery(caller, query, QueryId::FetchAllTafsirForSuite);
}


void QueryHelper::fetchQuote(QObject* caller, qint64 id)
{
    LOGGER(id);

    ATTACH_TAFSIR;
    QString query = QString("SELECT quotes.author AS author_id, body,reference,suite_id,uri FROM quotes INNER JOIN individuals ON individuals.id=quotes.author WHERE quotes.id=%1").arg(id);
    m_sql.executeQuery(caller, query, QueryId::FetchQuote);
}


void QueryHelper::fetchAyatsForTafsir(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    ATTACH_TAFSIR;

    QString query = QString("SELECT id,surah_id,from_verse_number,to_verse_number FROM explanations WHERE suite_page_id=%1 ORDER BY surah_id,from_verse_number,to_verse_number").arg(suitePageId);
    m_sql.executeQuery(caller, query, QueryId::FetchAyatsForTafsir);
}


void QueryHelper::fetchTafsirContent(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    ATTACH_TAFSIR;
    QString query = QString("SELECT %2 AS author,x.id AS author_id,x.hidden AS author_hidden,x.birth AS author_birth,x.death AS author_death,%3 AS translator,y.id AS translator_id,y.hidden AS translator_hidden,y.birth AS translator_birth,y.death AS translator_death,%4 AS explainer,z.id AS explainer_id,z.hidden AS explainer_hidden,z.birth AS explainer_birth,z.death AS explainer_death,title,description,suites.reference AS reference,suite_pages.reference AS suite_pages_reference,body,heading FROM suites INNER JOIN suite_pages ON suites.id=suite_pages.suite_id LEFT JOIN individuals x ON suites.author=x.id LEFT JOIN individuals y ON suites.translator=y.id LEFT JOIN individuals z ON suites.explainer=z.id WHERE suite_pages.id=%1").arg(suitePageId).arg( NAME_FIELD("x") ).arg( NAME_FIELD("y") ).arg( NAME_FIELD("z") );

    m_sql.executeQuery(caller, query, QueryId::FetchTafsirContent);
}


void QueryHelper::fetchSimilarAyatContent(QObject* caller, int chapterNumber, int verseNumber)
{
    LOGGER(chapterNumber << verseNumber);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT other_surah_id AS surah_id,other_from_verse_id AS verse_id,verses.translation AS content,chapters.transliteration AS name FROM related INNER JOIN ayahs ON related.other_surah_id=ayahs.surah_id AND related.other_from_verse_id=ayahs.verse_number INNER JOIN verses ON (ayahs.surah_id=verses.chapter_id AND ayahs.verse_number=verses.verse_id) INNER JOIN chapters ON chapters.id=related.other_surah_id WHERE related.surah_id=%1 AND from_verse_id=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchSimilarAyatContent);
    } else {
        m_sql.executeQuery(caller, QString("SELECT other_surah_id AS surah_id,other_from_verse_id AS verse_id,content,name FROM related INNER JOIN ayahs ON related.other_surah_id=ayahs.surah_id AND related.other_from_verse_id=ayahs.verse_number INNER JOIN surahs ON surahs.id=related.other_surah_id WHERE related.surah_id=%1 AND from_verse_id=%2").arg(chapterNumber).arg(verseNumber), QueryId::FetchSimilarAyatContent);
    }
}


void QueryHelper::fetchBio(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    ATTACH_TAFSIR;
    m_sql.executeQuery(caller, QString("SELECT mentions.id,%1 AS author,heading,title,suite_page_id,suites.reference,suite_pages.reference AS suite_page_reference,points FROM mentions INNER JOIN suite_pages ON mentions.suite_page_id=suite_pages.id INNER JOIN suites ON suites.id=suite_pages.suite_id LEFT JOIN individuals i ON suites.author=i.id WHERE target=%2").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchBio);
}


bool QueryHelper::searchQuery(QObject* caller, QString const& trimmedText, int chapterNumber, QVariantList const& additional, bool andMode)
{
    LOGGER(trimmedText << additional << andMode << chapterNumber);

    QVariantList params = QVariantList() << trimmedText;
    bool isArabic = trimmedText.isRightToLeft() || !showTranslation();
    QString query = ThreadUtils::buildSearchQuery(params, isArabic, chapterNumber, additional, andMode);

    m_sql.executeQuery(caller, query, QueryId::SearchAyats, params);

    return isArabic;
}


void QueryHelper::fetchTransliteration(QObject* caller, int chapter, int verse)
{
    LOGGER(chapter << verse);

    if ( showTranslation() ) {
        m_sql.executeQuery(caller, QString("SELECT html FROM transliteration WHERE chapter_id=%1 AND verse_id=%2").arg(chapter).arg(verse), QueryId::FetchTransliteration);
    }
}


void QueryHelper::fetchAllQuotes(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    ATTACH_TAFSIR;

    QStringList queryParams = QStringList() << QString("SELECT quotes.id AS id,%1 AS author,body,reference FROM quotes INNER JOIN individuals i ON i.id=quotes.author").arg( NAME_FIELD("i") );

    if (individualId) {
        queryParams << QString("WHERE quotes.author=%1").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql.executeQuery(caller, queryParams.join(" "), QueryId::FetchAllQuotes);
}


void QueryHelper::findDuplicateQuotes(QObject* caller, QString const& field)
{
    LOGGER(field);

    QString query = QString("SELECT quotes.id AS id,%1 AS author,body,reference,COUNT(*) c FROM quotes INNER JOIN individuals i ON i.id=quotes.author GROUP BY %2 HAVING c > 1").arg( NAME_FIELD("i") ).arg(field);
    m_sql.executeQuery(caller, query, QueryId::FindDuplicates);
}


void QueryHelper::setupTables()
{
    LOGGER("RunningSetup");
    QString srcLanguage = ENGLISH_TRANSLATION;
    QString srcTafsir = TAFSIR_NAME(srcLanguage);
    bool port = m_translation != srcLanguage && tafsirFileExists(srcTafsir) ;

    if (port) {
        m_sql.attachIfNecessary(srcTafsir, true);
    }

    ATTACH_TAFSIR;
    const QString currentTafsir = tafsirName();
    m_sql.startTransaction(NULL, QueryId::SettingUpTafsir);

    QStringList statements;
    statements << "CREATE TABLE IF NOT EXISTS %1.locations (id INTEGER PRIMARY KEY, city TEXT NOT NULL UNIQUE ON CONFLICT IGNORE, latitude REAL NOT NULL, longitude REAL NOT NULL);";
    statements << "CREATE TABLE IF NOT EXISTS %1.individuals (id INTEGER PRIMARY KEY, prefix TEXT, name TEXT, kunya TEXT, hidden INTEGER, birth INTEGER, death INTEGER, female INTEGER, displayName TEXT, location INTEGER REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE, is_companion INTEGER, CHECK(is_companion=1 AND female=1 AND hidden=1 AND name <> '' AND prefix <> '' AND kunya <> '' AND displayName <> ''));";
    statements << "CREATE TABLE IF NOT EXISTS %1.teachers (individual INTEGER NOT NULL REFERENCES individuals(id) ON DELETE CASCADE, teacher INTEGER NOT NULL REFERENCES individuals(id) ON DELETE CASCADE, UNIQUE(individual,teacher) ON CONFLICT IGNORE );";
    statements << "CREATE TABLE IF NOT EXISTS %1.websites (id INTEGER PRIMARY KEY, individual INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, uri TEXT NOT NULL, UNIQUE(individual, uri) ON CONFLICT IGNORE CHECK(uri <> '') );";
    statements << "CREATE TABLE IF NOT EXISTS %1.mentions (id INTEGER PRIMARY KEY, target INTEGER NOT NULL REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER NOT NULL REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE, points INTEGER, UNIQUE(target,suite_page_id) ON CONFLICT REPLACE);";
    statements << "CREATE TABLE IF NOT EXISTS %1.parents (individual INTEGER NOT NULL REFERENCES individuals(id) ON DELETE CASCADE, parent_id INTEGER NOT NULL REFERENCES individuals(id) ON DELETE CASCADE, UNIQUE(individual,parent_id) ON CONFLICT IGNORE );";
    statements << "CREATE TABLE IF NOT EXISTS %1.siblings (individual INTEGER NOT NULL REFERENCES individuals(id) ON DELETE CASCADE, sibling_id INTEGER NOT NULL REFERENCES individuals(id) ON DELETE CASCADE, UNIQUE(individual,sibling_id) ON CONFLICT IGNORE );";
    statements << "CREATE TABLE IF NOT EXISTS %1.suites (id INTEGER PRIMARY KEY, author INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, translator INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, explainer INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, title TEXT NOT NULL, description TEXT, reference TEXT, CHECK(title <> '' AND description <> '' AND reference <> ''));";
    statements << "CREATE TABLE IF NOT EXISTS %1.suite_pages (id INTEGER PRIMARY KEY, suite_id INTEGER NOT NULL REFERENCES suites(id) ON DELETE CASCADE, body TEXT NOT NULL, heading TEXT, reference TEXT, CHECK(body <> '' AND heading <> '' AND reference <> ''));";
    statements << "CREATE TABLE IF NOT EXISTS %1.quotes (id INTEGER PRIMARY KEY, author INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, body TEXT NOT NULL, reference TEXT, uri TEXT, suite_id INTEGER REFERENCES suites(id), CHECK(body <> '' AND reference <> '' AND uri <> '' AND (reference NOT NULL OR suite_id NOT NULL)));";
    statements << "CREATE TABLE IF NOT EXISTS %1.explanations (id INTEGER PRIMARY KEY, surah_id INTEGER NOT NULL, from_verse_number INTEGER, to_verse_number INTEGER, suite_page_id INTEGER NOT NULL REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE, UNIQUE(surah_id, from_verse_number, suite_page_id) ON CONFLICT REPLACE, CHECK(from_verse_number > 0 AND from_verse_number <= 286 AND to_verse_number >= from_verse_number AND to_verse_number <= 286 AND surah_id > 0 AND surah_id <= 114));";
    executeAndClear(statements);

    QStringList portStatements;
    if (port)
    {
        LOGGER("PortingFromEnglishDB...");
        portStatements << "INSERT INTO %1.locations SELECT * FROM %2.locations;";
        portStatements << "INSERT INTO %1.individuals SELECT * FROM %2.individuals;";
        portStatements << "INSERT INTO %1.teachers SELECT * FROM %2.teachers;";
        portStatements << "INSERT INTO %1.parents SELECT * FROM %2.parents;";
        portStatements << "INSERT INTO %1.siblings SELECT * FROM %2.siblings;";
        portStatements << "INSERT INTO %1.websites SELECT * FROM %2.websites;";
    }

    foreach (QString const& q, portStatements) {
        m_sql.executeInternal( q.arg(currentTafsir).arg(srcTafsir), QueryId::SettingUpTafsir);
    }

    statements << "CREATE INDEX IF NOT EXISTS %1.individuals_index ON individuals(birth,death,female,location,is_companion);";
    statements << "CREATE INDEX IF NOT EXISTS %1.suites_index ON suites(author,translator,explainer);";
    statements << "CREATE INDEX IF NOT EXISTS %1.suite_pages_index ON suite_pages(suite_id);";
    statements << "CREATE INDEX IF NOT EXISTS %1.quotes_index ON quotes(author);";
    statements << "CREATE INDEX IF NOT EXISTS %1.explanations_index ON explanations(to_verse_number);";
    executeAndClear(statements);

    m_sql.endTransaction(NULL, QueryId::SetupTafsir);
    LOGGER("ClearingTafsirVersion...");
    m_persist->setFlag( KEY_TAFSIR_VERSION(m_translation) );

    if (port) {
        m_sql.detach(srcTafsir);
    }

    LOGGER("SetupCompleted");
}


void QueryHelper::executeAndClear(QStringList& statements)
{
    const QString currentTafsir = tafsirName();

    foreach (QString const& q, statements) {
        m_sql.executeInternal( q.arg(currentTafsir), QueryId::SettingUpTafsir);
    }

    statements.clear();
}


qint64 QueryHelper::addBioLink(QObject* caller, qint64 suitePageId, qint64 targetId, QVariant const& points)
{
    LOGGER(suitePageId << targetId << points);

    qint64 id = QDateTime::currentMSecsSinceEpoch();

    QString query = "INSERT INTO mentions (id,target,suite_page_id,points) VALUES(?,?,?,?)";
    m_sql->executeQuery(caller, query, QueryId::AddBioLink, QVariantList() << id << targetId << suitePageId << points);

    return id;
}


void QueryHelper::addWebsite(QObject* caller, qint64 individualId, QString const& address)
{
    LOGGER(individualId << address);
    QString query = QString("INSERT INTO websites (individual,uri) VALUES(%1,?)").arg(individualId);
    m_sql->executeQuery(caller, query, QueryId::AddWebsite, QVariantList() << address);
}


qint64 QueryHelper::addLocation(QObject* caller, QString const& city, qreal latitude, qreal longitude)
{
    LOGGER(city << latitude << longitude);

    qint64 now = QDateTime::currentMSecsSinceEpoch();

    QString query = "INSERT INTO locations (id,city,latitude,longitude) VALUES(?,?,?,?)";
    m_sql->executeQuery(caller, query, QueryId::AddLocation, QVariantList() << now << city << latitude << longitude);

    return now;
}


void QueryHelper::addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference, QString const& suiteId, QString const& uri)
{
    LOGGER(author << body << reference << suiteId << uri);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("INSERT INTO quotes (author,body,reference,suite_id,uri) VALUES(%1,?,?,?,?)").arg(authorId);
    QVariantList args = QVariantList() << body << reference;
    args <<  ( !suiteId.isEmpty() ? suiteId.toLongLong() : QVariant() );
    args << protect(uri);

    m_sql->executeQuery(caller, query, QueryId::AddQuote, args);
}


void QueryHelper::addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(author << translator << explainer << title << description << reference);

    QStringList fields = QStringList() << "id" << "title" << "description" << "reference";
    QVariantList args = QVariantList() << QDateTime::currentMSecsSinceEpoch() << title << protect(description) << reference;

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


void QueryHelper::addTafsirPage(QObject* caller, qint64 suiteId, QString const& body, QString const& heading, QString const& reference)
{
    LOGGER( suiteId << body.length() << reference.length() );

    QString query = QString("INSERT OR IGNORE INTO suite_pages (id,suite_id,body,heading,reference) VALUES(%1,%2,?,?,?)").arg( QDateTime::currentMSecsSinceEpoch() ).arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::AddTafsirPage, QVariantList() << body << protect(heading) << protect(reference) );
}


void QueryHelper::addStudent(QObject* caller, qint64 teacherId, qint64 studentId)
{
    LOGGER(teacherId << studentId);

    QString query = QString("INSERT OR IGNORE INTO teachers(teacher,individual) VALUES(%1,%2)").arg(teacherId).arg(studentId);
    m_sql->executeQuery(caller, query, QueryId::AddStudent);
}


void QueryHelper::addTeacher(QObject* caller, qint64 studentId, qint64 teacherId)
{
    LOGGER(studentId << teacherId);

    QString query = QString("INSERT OR IGNORE INTO teachers(individual,teacher) VALUES(%1,%2)").arg(studentId).arg(teacherId);
    m_sql->executeQuery(caller, query, QueryId::AddTeacher);
}


void QueryHelper::editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference)
{
    LOGGER(suiteId << author << translator << explainer << title << description << reference);

    QStringList fields = QStringList() << "author=?" << "title=?" << "description=?" << "reference=?" << "translator=?" << "explainer=?";
    QVariantList args = QVariantList() << generateIndividualField(caller, author);
    args << title;
    args << protect(description);
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


void QueryHelper::editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body, QString const& heading, QString const& reference)
{
    LOGGER( suitePageId << body.length() << heading.length() << reference.length() );

    QString query = QString("UPDATE suite_pages SET body=?, heading=?, reference=? WHERE id=%1").arg(suitePageId);
    m_sql->executeQuery( caller, query, QueryId::EditTafsirPage, QVariantList() << body << protect(heading) << protect(reference) );
}


void QueryHelper::editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, bool companion)
{
    LOGGER( id << prefix << name << kunya << displayName << hidden << birth << death << female << location );

    QString query = QString("UPDATE individuals SET prefix=?, name=?, kunya=?, displayName=?, hidden=?, birth=?, death=?, female=?, location=?, is_companion=? WHERE id=%1").arg(id);

    QVariantList args;
    args << protect(prefix);
    args << name;
    args << protect(kunya);
    args << protect(displayName);
    args << ( hidden ? 1 : QVariant() );
    args << ( birth != 0 ? birth : QVariant() );
    args << ( death != 0 ? death : QVariant() );
    args << ( female ? 1 : QVariant() );
    args << ( !location.isEmpty() ? location.toLongLong() : QVariant() );
    args << ( companion ? 1 : QVariant() );

    m_sql->executeQuery(caller, query, QueryId::EditIndividual, args);
}


void QueryHelper::editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference, QString const& suiteId, QString const& uri)
{
    LOGGER(quoteId << author << body << reference << suiteId << uri);

    qint64 authorId = generateIndividualField(caller, author);
    QString query = QString("UPDATE quotes SET author=%2,body=?,reference=?,suite_id=?,uri=? WHERE id=%1").arg(quoteId).arg(authorId);
    QVariantList args = QVariantList() << body << reference;
    args << ( !suiteId.isEmpty() ? suiteId.toLongLong() : QVariant() );
    args << protect(uri);

    m_sql->executeQuery(caller, query, QueryId::EditQuote, args);
}


void QueryHelper::editLocation(QObject* caller, qint64 id, QString const& city)
{
    LOGGER(id << city);

    QString query = QString("UPDATE locations SET city=? WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::EditLocation, QVariantList() << city);
}


void QueryHelper::fetchAllIndividuals(QObject* caller, bool companionsOnly, bool orderByDeath)
{
    QString query = "SELECT i.id,%1 AS name,is_companion FROM individuals i ORDER BY displayName,name";
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


void QueryHelper::fetchAllLocations(QObject* caller, QString const& city)
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


void QueryHelper::fetchBioMetadata(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);
    m_sql->executeQuery(caller, QString("SELECT mentions.id,%1 AS target,points,mentions.target AS target_id FROM mentions LEFT JOIN individuals i ON mentions.target=i.id WHERE suite_page_id=%2").arg( NAME_FIELD("i") ).arg(suitePageId), QueryId::FetchBioMetadata);
}


void QueryHelper::fetchTeachers(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS teacher FROM teachers INNER JOIN individuals i ON teachers.teacher=i.id WHERE teachers.individual=%2 AND i.hidden ISNULL").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchTeachers);
}


void QueryHelper::fetchStudents(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT i.id,%1 AS student FROM teachers INNER JOIN individuals i ON teachers.individual=i.id WHERE teachers.teacher=%2 AND i.hidden ISNULL").arg( NAME_FIELD("i") ).arg(individualId), QueryId::FetchStudents);
}


void QueryHelper::fetchFrequentIndividuals(QObject* caller, QString const& table, QString const& field, int n)
{
    m_sql->executeQuery(caller, QString("SELECT %4 AS id,%2 AS name,is_companion FROM (SELECT %4,COUNT(%4) AS n FROM %3 GROUP BY %4 ORDER BY n DESC LIMIT %1) INNER JOIN individuals i ON i.id=%4 GROUP BY i.id ORDER BY name").arg(n).arg( NAME_FIELD("i") ).arg(table).arg(field), QueryId::FetchAllIndividuals);
}


void QueryHelper::fetchAllWebsites(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);
    m_sql->executeQuery(caller, QString("SELECT id,uri FROM websites WHERE individual=%1 ORDER BY uri").arg(individualId), QueryId::FetchAllWebsites);
}


void QueryHelper::fetchAllTafsir(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QStringList queryParams = QStringList() << QString("SELECT suites.id AS id,%1 AS author,title FROM suites LEFT JOIN individuals i ON i.id=suites.author").arg( NAME_FIELD("i") );

    if (individualId) {
        queryParams << QString("WHERE (author=%1 OR translator=%1 OR explainer=%1)").arg(individualId);
    }

    queryParams << "ORDER BY id DESC";

    m_sql->executeQuery(caller, queryParams.join(" "), QueryId::FetchAllTafsir);
}


void QueryHelper::findDuplicateSuites(QObject* caller, QString const& field)
{
    LOGGER(field);

    QString query = QString("SELECT suites.id AS id,%1 AS author,title,COUNT(*) c FROM suites LEFT JOIN individuals i ON i.id=suites.author GROUP BY %2 HAVING c > 1").arg( NAME_FIELD("i") ).arg(field);
    m_sql->executeQuery(caller, query, QueryId::FindDuplicates);
}


void QueryHelper::fetchTafsirMetadata(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("SELECT author,translator,explainer,title,description,reference FROM suites WHERE id=%1").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::FetchTafsirHeader);
}


void QueryHelper::fetchIndividualData(QObject* caller, qint64 individualId)
{
    LOGGER(individualId);

    QString query = QString("SELECT * FROM individuals WHERE id=%1").arg(individualId);
    m_sql->executeQuery(caller, query, QueryId::FetchIndividualData);
}


qint64 QueryHelper::generateIndividualField(QObject* caller, QString const& value)
{
    static QRegExp allNumbers = QRegExp("\\d+");

    if ( allNumbers.exactMatch(value) ) {
        return value.toLongLong();
    } else {
        qint64 id = QDateTime::currentMSecsSinceEpoch();

        if ( value.startsWith("Shaykh ") || value.startsWith("Sheikh ") || value.startsWith("Imam ") || value.startsWith("Imaam ") )
        {
            QStringList all = value.split(" ");
            QString prefix = all.takeFirst();
            QString actualName = all.join(" ");

            m_sql->executeQuery(caller, QString("INSERT INTO individuals (id,prefix,name) VALUES (%1,?,?)").arg(id), QueryId::AddIndividual, QVariantList() << prefix << actualName);
        } else {
            m_sql->executeQuery(caller, QString("INSERT INTO individuals (id,name) VALUES (%1,?)").arg(id), QueryId::AddIndividual, QVariantList() << value);
        }

        return id;
    }
}


qint64 QueryHelper::createIndividual(QObject* caller, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, int birth, int death, QString const& location, bool companion)
{
    LOGGER( prefix << name << kunya << displayName << birth << death << location << companion );

    qint64 id = QDateTime::currentMSecsSinceEpoch();
    QString query = QString("INSERT INTO individuals (id,prefix,name,kunya,displayName,birth,death,location,is_companion) VALUES (%1,?,?,?,?,?,?,?,?)").arg(id);

    QVariantList args;
    args << protect(prefix);
    args << name;
    args << protect(kunya);
    args << protect(displayName);
    args << ( birth != 0 ? birth : QVariant() );
    args << ( death != 0 ? death : QVariant() );
    args << ( !location.isEmpty() ? location.toLongLong() : QVariant() );
    args << ( companion ? 1 : QVariant() );

    m_sql->executeQuery(caller, query, QueryId::AddIndividual, args);

    return id;
}


void QueryHelper::linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse, QueryId::Type linkId)
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


void QueryHelper::linkAyatsToTafsir(QObject* caller, qint64 suitePageId, QVariantList const& chapterVerseData)
{
    m_sql->startTransaction(caller, QueryId::LinkingAyatsToTafsir);

    foreach (QVariant const& q, chapterVerseData)
    {
        QVariantMap qvm = q.toMap();
        linkAyatToTafsir( caller, suitePageId, qvm.value(CHAPTER_KEY).toInt(), qvm.value(FROM_VERSE_KEY).toInt(), qvm.value(TO_VERSE_KEY).toInt() );
    }

    m_sql->endTransaction(caller, QueryId::LinkAyatsToTafsir);
}


void QueryHelper::removeBioLink(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM mentions WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveBioLink);
}


void QueryHelper::removeQuote(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM quotes WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveQuote);
}


void QueryHelper::removeWebsite(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM websites WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveWebsite);
}


void QueryHelper::removeIndividual(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM individuals WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveIndividual);
}


void QueryHelper::removeLocation(QObject* caller, qint64 id)
{
    LOGGER(id);
    QString query = QString("DELETE FROM locations WHERE id=%1").arg(id);
    m_sql->executeQuery(caller, query, QueryId::RemoveLocation);
}


void QueryHelper::removeTafsir(QObject* caller, qint64 suiteId)
{
    LOGGER(suiteId);

    QString query = QString("DELETE FROM suites WHERE id=%1").arg(suiteId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTafsir);
}


void QueryHelper::removeTeacher(QObject* caller, qint64 individual, qint64 teacherId)
{
    LOGGER(individual << teacherId);

    QString query = QString("DELETE FROM teachers WHERE individual=%1 AND teacher=%2").arg(individual).arg(teacherId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTeacher);
}


void QueryHelper::removeStudent(QObject* caller, qint64 individual, qint64 studentId)
{
    LOGGER(individual << studentId);

    QString query = QString("DELETE FROM teachers WHERE teacher=%1 AND individual=%2").arg(individual).arg(studentId);
    m_sql->executeQuery(caller, query, QueryId::RemoveStudent);
}


void QueryHelper::removeTafsirPage(QObject* caller, qint64 suitePageId)
{
    LOGGER(suitePageId);

    QString query = QString("DELETE FROM suite_pages WHERE id=%1").arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::RemoveTafsirPage);
}


void QueryHelper::replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId)
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


void QueryHelper::mergeSuites(QObject* caller, QVariantList const& toReplaceIds, qint64 actualId)
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


void QueryHelper::searchIndividuals(QObject* caller, QString const& trimmedText)
{
    LOGGER(trimmedText);
    m_sql->executeQuery(caller, QString("SELECT id,%2 AS name,is_companion FROM individuals i WHERE %1 ORDER BY displayName,name").arg( NAME_SEARCH("i") ).arg( NAME_FIELD("i") ), QueryId::SearchIndividuals, QVariantList() << trimmedText << trimmedText << trimmedText);
}


void QueryHelper::searchQuote(QObject* caller, QString fieldName, QString const& searchTerm)
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


void QueryHelper::searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm)
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


void QueryHelper::unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId)
{
    LOGGER(ids << suitePageId);

    QString query = QString("DELETE FROM explanations WHERE id IN (%1) AND suite_page_id=%2").arg( combine(ids) ).arg(suitePageId);
    m_sql->executeQuery(caller, query, QueryId::UnlinkAyatsFromTafsir);
}


void QueryHelper::updateTafsirLink(QObject* caller, qint64 explanationId, int surahId, int fromVerse, int toVerse)
{
    LOGGER(explanationId << surahId << fromVerse << toVerse);

    QString query = QString("UPDATE explanations SET surah_id=%2,from_verse_number=%3,to_verse_number=%4 WHERE id=%1").arg(explanationId).arg(surahId).arg(fromVerse).arg(toVerse);
    m_sql->executeQuery(caller, query, QueryId::UpdateTafsirLink);
}


QueryHelper::~QueryHelper()
{
}

} /* namespace oct10 */
