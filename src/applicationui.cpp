#include "precompiled.h"

#include "applicationui.hpp"
#include "CommonConstants.h"
#include "IOUtils.h"
#include "JlCompress.h"
#include "Logger.h"

#include <bb/pim/contacts/ContactService>
#include <bb/pim/contacts/ContactBuilder>
#include <bb/pim/contacts/ContactAttributeBuilder>

#define COOKIE_GEO_LOOKUP "geo"
#define COOKIE_DLOAD_ILM_DB "download_ilm_db"
#define COOKIE_DB_CHATS "chats"
#define COOKIE_DB_ILM "ilm"
#define COOKIE_UPLOAD_DB "upload_db"
#define COOKIE_USER_LOOKUP "user_lookup"
#define FIELD_ID "id"
#define FIELD_TABLE_NAME "table_name"
#define TRANSLATION m_persistance.getValueFor("translation").toString()

using namespace bb::pim::contacts;


namespace {

QUrl generateGeocodingUrl()
{
    QUrl url;
    url.setScheme("https");
    url.setHost("maps.googleapis.com");
    url.setPath("maps/api/geocode/json");
    url.addQueryItem("key", "apiKey");

    return url;
}

QUrl generateBasePath(QString const& path)
{
    QUrl url;
    url.setScheme("http");
    url.setUserName("username");
    url.setPassword("password");
    url.setHost("host");
    url.setPath(path);

    return url;
}

}

namespace admin {

using namespace bb::cascades;
using namespace bb::system;
using namespace canadainc;

ApplicationUI::ApplicationUI(bb::system::InvokeManager* im) :
        m_sql( QString("%1/master.db").arg( QDir::homePath() ) ),
        m_persistance(im), m_ilm(&m_sql), m_ilmTest(&m_sql),
        m_quran(&m_sql), m_tafsir(&m_sql), m_salat(&m_sql),
        m_sunnah(&m_sql), m_invoke(im, &m_tafsir)
{
    switch ( im->startupMode() )
    {
        case ApplicationStartupMode::LaunchApplication:
            init("main.qml");
            break;

        case ApplicationStartupMode::InvokeCard:
            connect( im, SIGNAL( cardPooled(bb::system::CardDoneMessage const&) ), QCoreApplication::instance(), SLOT( quit() ) );
            connect( im, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
            break;
        case ApplicationStartupMode::InvokeApplication:
            connect( im, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
            break;

        default:
            break;
    }

    connect( im, SIGNAL( childCardDone(bb::system::CardDoneMessage const&) ), this, SLOT( childCardDone(bb::system::CardDoneMessage const&) ) );
}


void ApplicationUI::invoked(bb::system::InvokeRequest const& request)
{
    if ( request.uri().toString().startsWith("http://appworld.blackberry.com") ) {
        m_persistance.downloadApp( request.uri().toString().split("/").last() );
        m_persistance.invokeManager()->sendCardDone( CardDoneMessage() );
    } else {
        init( m_invoke.invoked(request) );
    }
}


void ApplicationUI::init(QString const& qmlDoc)
{
    QMap<QString, QObject*> context;
    context["ilmTest"] = &m_ilmTest;
    context["ilmHelper"] = &m_ilm;
    context["invokeHelper"] = &m_invoke;
    context["quran"] = &m_quran;
    context["salat"] = &m_salat;
    context["sunnah"] = &m_sunnah;
    context["tafsirHelper"] = &m_tafsir;
    context["textUtils"] = &m_textUtils;
    context["sql"] = &m_sql;

    setErrorHandler(&Persistance::onErrorMessage);

    m_invoke.init(qmlDoc, context, this);

    emit initialize();
}


void ApplicationUI::childCardDone(bb::system::CardDoneMessage const& message)
{
    LOGGER( message.data() );
    emit childCardFinished( message.data(), message.reason().split("/").last() );

    if ( !message.data().isEmpty() ) {
        m_persistance.invokeManager()->sendCardDone(message);
    }
}


void ApplicationUI::compressIlmDatabase(bool notifyClients)
{
    emit compressing();

    m_watcher.addPath( QDir::tempPath() );

    QFuture<UploadData> future = QtConcurrent::run( &ThreadUtils::compressDatabase, databasePath(), notifyClients, QDir::homePath(), QString(COOKIE_DB_ILM) );
    m_compressor.setFuture(future);
}


void ApplicationUI::doDiff(QVariantList const& input, bb::cascades::ArrayDataModel* adm, QString const& key)
{
    QSet<qint64> keys;

    for (int i = adm->size()-1; i >= 0; i--) {
        keys << adm->value(i).toMap().value(key).toLongLong();
    }

    foreach (QVariant const& x, input)
    {
        if ( !keys.contains( x.toMap().value(key).toLongLong() ) ) {
            adm->insert(0, x);
        }
    }

    /*
    if ( adm->isEmpty() ) {
        adm->append(input);
    } else {
        bool same = true;
        int oldSize = adm->size();
        QSet<qint64> oldKeys;
        QSet<qint64> newKeys;

        if ( oldSize == adm->size() )
        {
            for (int i = oldSize-1; i >= 0; i--)
            {
                QVariantMap oldElement = adm->value(i).toMap();
                qint64 oldKey = oldElement.value(key).toLongLong();
                oldKeys << oldKey;
                QVariantMap newElement = input[i].toMap();
                qint64 newKey = newElement.value(key).toLongLong();
                newKeys << newKey;

                if (oldElement != newElement)
                {
                    if (oldKey == newKey) {
                        adm->replace(i, newElement);
                    } else {
                        same = false;
                    }
                }
            }
        }

        if (!same) // there were additions or removals
        {
            QSet<qint64> toRemove = oldKeys.subtract(newKeys); // remove all the items that are in the old that are in the new one = toAdd
            QSet<qint64> toAdd = newKeys.subtract(oldKeys); // remove all the items that are in the new that are in the old one

            for (int i = oldSize-1; i >= 0; i--)
            {
                QVariantMap oldElement = adm->value(i).toMap();
                qint64 oldKey = oldElement.value(key).toLongLong();
                oldKeys << oldKey;
                QVariantMap newElement = input[i].toMap();
                qint64 newKey = newElement.value(key).toLongLong();
                newKeys << newKey;

                if (oldElement != newElement)
                {
                    if (oldKey == newKey) {
                        adm->replace(i, newElement);
                    } else {
                        same = false;
                    }
                }
            }

            for (int i = oldSize-1; i >= 0; i--)
            {
                qint64 currentKey = adm->value(i).toMap().value(key).toLongLong();

                if ( toRemove.contains(currentKey) ) {
                    adm->removeAt(i);
                }
            }

            foreach (QVariant const& q, input)
            {
                qint64 currentKey = q.toMap().value(key).toLongLong();

                if ( toAdd.contains(currentKey) ) {
                    adm->insert(0,q);
                }
            }
        }
    } */
}


void ApplicationUI::createContacts(QString const& filePath)
{
    ContactService service;

    QFile outputFile(filePath);
    bool opened = outputFile.open(QIODevice::ReadOnly);

    if (opened)
    {
        int total = outputFile.size();
        const int chunkSize = total*0.1;
        QTextStream stream(&outputFile);
        QString result;

        while ( !stream.atEnd() ) {
            result += stream.read(chunkSize);
        }

        outputFile.close();

        QStringList lines = result.trimmed().split("\n");

        for (int i = 0; i < lines.size(); i++)
        {
            QString line = lines[i];

            ContactBuilder builder;
            builder.addAttribute(ContactAttributeBuilder()
                                 .setKind(AttributeKind::Name)
                                 .setSubKind(AttributeSubKind::NameGiven)
                                 .setValue( QString("X%1").arg(i) ));
            builder.addAttribute(ContactAttributeBuilder()
                                 .setKind(AttributeKind::Phone)
                                 .setSubKind(AttributeSubKind::PhoneMobile)
                                 .setValue( QString("+%1").arg(line) ));
            Contact createdContact = service.createContact(builder, false);
        }
    } else {
        LOGGER("Could not open");
    }
}


void ApplicationUI::createContactCard(QString const& name, QStringList const& whatsapp, QStringList const& bbm)
{
    ContactService service;

    ContactBuilder builder;
    builder.addAttribute(ContactAttributeBuilder()
                         .setKind(AttributeKind::Name)
                         .setSubKind(AttributeSubKind::NameGiven)
                         .setValue(name));

    foreach (QString const& number, whatsapp)
    {
        builder.addAttribute(ContactAttributeBuilder()
                             .setKind(AttributeKind::Phone)
                             .setSubKind(AttributeSubKind::PhoneMobile)
                             .setValue( QString("+%1").arg(number) ));
    }

    foreach (QString const& pin, bbm)
    {
        builder.addAttribute(ContactAttributeBuilder()
                             .setKind(AttributeKind::InstantMessaging)
                             .setSubKind(AttributeSubKind::InstantMessagingBbmPin)
                             .setValue(pin));
    }

    service.createContact(builder, false);
}


void ApplicationUI::onSettingChanged(QString const& key)
{
    if (key == "translation")
    {
        m_sql.detach(m_dbFile);
        m_source.close();
        m_target.close();

        if ( !m_watcher.directories().isEmpty() ) {
            m_watcher.removePaths( m_watcher.directories() );
        }

        if ( !m_watcher.files().isEmpty() ) {
            m_watcher.removePaths( m_watcher.files() );
        }

        loadIlmDatabase();
        emit textualChange();
    }
}


void ApplicationUI::onCompressed()
{
    m_watcher.removePath(ILM_DB_ARCHIVE_DESTINATION);

    QFutureWatcher<UploadData>* qfw = static_cast< QFutureWatcher<UploadData>* >( sender() );
    UploadData r = qfw->result();
    QByteArray result = r.data;
    bool success = result.size() > 0;

    LOGGER( result.size() );

    if (success)
    {
        if (r.cookie == COOKIE_DB_ILM)
        {
            QUrl url = generateBasePath("/admin/upload_ilm_master.php");
            url.addQueryItem("language", TRANSLATION);
            url.addQueryItem("md5", r.md5);
            url.addQueryItem("notifyClients", r.notifyClients ? "1" : "0");
            m_network.upload(url, "plugins.zip", result, COOKIE_UPLOAD_DB);
        } else if (r.cookie == COOKIE_DB_CHATS) {
            QUrl url = generateBasePath("/admin/upload_chats.php");
            url.addQueryItem("md5", r.md5);
            m_network.upload(url, "plugins.zip", result, COOKIE_UPLOAD_DB);
        }
    } else {
        LOGGER("No success!" << success);
    }

    emit compressed(success);
}


void ApplicationUI::onDirectoryChanged(QString const& path)
{
    Q_UNUSED(path);

    if ( QFile(ILM_DB_ARCHIVE_DESTINATION).exists() )
    {
        m_watcher.removePath( QDir::tempPath() );
        m_watcher.addPath(ILM_DB_ARCHIVE_DESTINATION);

        m_source.setFileName( QString("%1/%2.db").arg( QDir::homePath() ).arg(m_dbFile) );
        m_target.setFileName(ILM_DB_ARCHIVE_DESTINATION);
    }
}


void ApplicationUI::onFileChanged(QString const& path)
{
    Q_UNUSED(path);
    emit compressProgress( m_target.size(), m_source.size()/4 ); // assume 75% compression
}


void ApplicationUI::onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error)
{
    QString id = cookie.toString();
    LOGGER(id);

    if (id == COOKIE_UPLOAD_DB)
    {
        QVariantMap actualResult = bb::data::JsonDataAccess().loadFromBuffer(data).toMap();
        QString httpResult = actualResult.value("result").toString();
        bool success = !error && httpResult == HTTP_RESPONSE_OK;

        LOGGER(actualResult);

        if (success) {
            m_persistance.showToast( tr("Successfully submitted updates!"), "images/toast/success_upload_local.png" );
        } else {
            m_persistance.showToast( tr("Update submission failed!"), "images/menu/ic_remove_choice.png" );
        }
    } else if (id == COOKIE_DLOAD_ILM_DB) {
        QString target = QString("%1/%2.zip").arg( QDir::tempPath() ).arg(m_dbFile);
        bool written = IOUtils::writeFile(target, data);

        if (written)
        {
            QStringList files = JlCompress::extractDir( target, QDir::homePath(), ILM_ARCHIVE_PASSWORD );
            written = !files.isEmpty();
        }

        if (written) {
            m_persistance.showToast("Successfully setup downloaded database!", "images/menu/ic_accept.png");
        } else {
            m_persistance.showToast("Couldn't process the downloaded database!", "images/toast/ic_no_ayat_found.png");
        }
    } else if (id == COOKIE_GEO_LOOKUP) {
        LOGGER("Locations found!");
        QVariant result = bb::data::JsonDataAccess().loadFromBuffer(data);
        emit locationsFound(result);
    } else if (id == COOKIE_USER_LOOKUP) {
        LOGGER("User results!");
        QVariant result = bb::data::JsonDataAccess().loadFromBuffer(data);
        emit userFound(result);
    }

    emit requestComplete();
}


void ApplicationUI::loadIlmDatabase(bool force)
{
    QString translation = TRANSLATION;

    if ( translation.isNull() ) {
        translation = "english";
    }

    QString dbFile = databasePath();

    if ( !QFile::exists( QString("%1/%2.db").arg( QDir::homePath() ).arg(dbFile) ) || force )
    {
        bool yes = m_persistance.showBlockingDialog("Download?", "Do you want to download the Ilm database?");

        if (yes)
        {
            QUrl url = generateBasePath( QString("/admin/%1.zip").arg(dbFile) );
            m_network.doGet(url, COOKIE_DLOAD_ILM_DB);
        }
    } else {
        m_sql.attachIfNecessary(dbFile, true);
    }

    m_dbFile = dbFile;
    m_ilm.setDatabaseName(dbFile);
    m_quran.setDatabaseName(dbFile);
    m_tafsir.setDatabaseName(dbFile);
}


void ApplicationUI::lookupUser(QString const& address, bool userId)
{
    QUrl url;
    url.setScheme("http");
    url.setHost("host");
    url.setUserName("user");
    url.setPassword("password");
    url.setPath("path");
    url.addQueryItem(userId ? "user_id" : "address", address);

    m_network.doGet(url, COOKIE_USER_LOOKUP);
}


void ApplicationUI::lazyInit()
{
    INIT_SETTING("translation", "english");

    disconnect( this, SIGNAL( initialize() ), this, SLOT( lazyInit() ) ); // in case we get invoked again

    connect( &m_network, SIGNAL( requestComplete(QVariant const&, QByteArray const&, bool) ), this, SLOT( onRequestComplete(QVariant const&, QByteArray const&, bool) ) );
    connect( &m_network, SIGNAL( downloadProgress(QVariant const&, qint64, qint64) ), this, SIGNAL( transferProgress(QVariant const&, qint64, qint64) ) );
    connect( &m_network, SIGNAL( uploadProgress(QVariant const&, qint64, qint64) ), this, SIGNAL( transferProgress(QVariant const&, qint64, qint64) ) );
    connect( &m_watcher, SIGNAL( directoryChanged(QString const&) ), this, SLOT( onDirectoryChanged(QString const&) ) );
    connect( &m_watcher, SIGNAL( fileChanged(QString const&) ), this, SLOT( onFileChanged(QString const&) ) );
    connect( &m_compressor, SIGNAL( finished() ), this, SLOT( onCompressed() ) );
    connect( &m_persistance, SIGNAL( settingChanged(QString const&) ), this, SLOT( onSettingChanged(QString const&) ) );
    connect( QCoreApplication::instance(), SIGNAL( aboutToQuit() ), &m_compressor, SLOT( cancel() ) );

    m_sql.createDatabaseIfNotExists();
    //m_sql.setVerboseLogging();

    loadIlmDatabase();

    m_sql.enableForeignKeys();
    m_ilm.lazyInit();
    m_quran.lazyInit();
    m_ilmTest.lazyInit();
    m_salat.lazyInit();
    m_sunnah.lazyInit();
    m_tafsir.lazyInit();
    m_invoke.lazyInit();

    m_invoke.process();

    connect( &m_sql, SIGNAL( error(QString const&) ), &m_persistance, SLOT( onError(QString const&) ) );
    connect( &m_sql, SIGNAL( setupError(QString const&) ), &m_persistance, SLOT( onError(QString const&) ) );

    emit lazyInitComplete();
}


void ApplicationUI::geoLookup(QString const& location)
{
    LOGGER(location);

    QUrl url = generateGeocodingUrl();
    url.addQueryItem("address", location);

    m_network.doGet(url, COOKIE_GEO_LOOKUP);
}


void ApplicationUI::geoLookup(qreal latitude, qreal longitude)
{
    LOGGER(latitude << longitude);

    QUrl url = generateGeocodingUrl();
    url.addQueryItem( "latlng", QString("%1,%2").arg(latitude).arg(longitude) );

    m_network.doGet(url, COOKIE_GEO_LOOKUP);
}


void ApplicationUI::fetchAllIds(QObject* caller, QString const& table)
{
    CustomSqlDataSource* handle = m_sql.getHandle();
    handle->setQuery( QString("SELECT A.%2 + 1 AS %2 FROM %1 AS A WHERE NOT EXISTS (SELECT B.%2 FROM %1 AS B WHERE A.%2 + 1 = B.%2) GROUP BY A.%2 LIMIT 1").arg(table).arg(FIELD_ID) );
    DataAccessReply dar = handle->executeAndWait(QVariant());
    QVariantList resultSet = dar.result().toList();

    if ( !resultSet.isEmpty() )
    {
        qint64 id = resultSet.first().toMap().value(FIELD_ID).toLongLong();

        handle->setQuery( QString("SELECT %1 FROM %2 WHERE %1 > %3").arg(FIELD_ID).arg(table).arg(id) );
        dar = handle->executeAndWait(QVariant());
        resultSet = dar.result().toList();

        handle->startTransaction(10);

        foreach (QVariant const& q, resultSet) {
            handle->setQuery( QString("UPDATE %1 SET %2=%3 WHERE %2=%4").arg(table).arg(FIELD_ID).arg(id++).arg( q.toMap().value("id").toLongLong() ) );
            dar = handle->executeAndWait(QVariant());
        }

        handle->endTransaction(10);
    }
}


void ApplicationUI::setIndexAsId(QObject* caller, QVariantList const& data, QVariantList const& intersection)
{
    QSet<qint64> commonIds;

    foreach (QVariant q, intersection) {
        commonIds << q.toMap().value(FIELD_ID).toLongLong();
    }

    m_sql.startTransaction(caller, InternalQueryId::PendingTransaction);

    for (int i = 0; i < data.size(); i++)
    {
        QVariantMap current = data[i].toMap();
        QString table = current.value(FIELD_TABLE_NAME).toString();
        qint64 id = current.value(FIELD_ID).toLongLong();
        qint64 target = i+1;

        if ( id != target && !commonIds.contains(id) ) {
            m_sql.executeQuery(caller, QString("UPDATE %1 SET %4=%3 WHERE %4=%2").arg(table).arg(id).arg(target).arg(FIELD_ID), InternalQueryId::PendingTransaction);
        }
    }

    m_sql.endTransaction(caller, QueryId::UpdateIdWithIndex);
}


void ApplicationUI::uploadChats()
{
    emit compressing();

    m_watcher.addPath( QDir::tempPath() );

    QFuture<UploadData> future = QtConcurrent::run( &ThreadUtils::compressDatabase, QString("master"), false, QString("/var/tmp"), QString(COOKIE_DB_CHATS) );
    m_compressor.setFuture(future);
}


QString ApplicationUI::databasePath() {
    return ILM_DB_FILE(TRANSLATION);
}

}
