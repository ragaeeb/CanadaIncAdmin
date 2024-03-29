#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "DatabaseHelper.h"
#include "IlmHelper.h"
#include "IlmTestHelper.h"
#include "InvokeHelper.h"
#include "NetworkProcessor.h"
#include "Persistance.h"
#include "QuranHelper.h"
#include "SalatHelper.h"
#include "SunnahHelper.h"
#include "TafsirHelper.h"
#include "TextUtils.h"
#include "ThreadUtils.h"

#include <bb/system/CardDoneMessage>

namespace bb {
    namespace cascades {
        class ArrayDataModel;
    }
}

namespace admin {

using namespace canadainc;

class ApplicationUI : public QObject
{
    Q_OBJECT

    DatabaseHelper m_sql;
    Persistance m_persistance;
    NetworkProcessor m_network;
    ilm::IlmHelper m_ilm;
    ilmtest::IlmTestHelper m_ilmTest;
    quran::QuranHelper m_quran;
    TafsirHelper m_tafsir;
    SalatHelper m_salat;
    sunnah::SunnahHelper m_sunnah;
    QFileSystemWatcher m_watcher;
    QFile m_source;
    QFile m_target;
    InvokeHelper m_invoke;
    TextUtils m_textUtils;
    QFutureWatcher<UploadData> m_compressor;
    QString m_dbFile;

    void init(QString const& qml);

signals:
    void childCardFinished(QString const& message, QString const& cookie);
    void compressed(bool success);
    void compressProgress(qint64 current, qint64 total);
    void compressing();
    void initialize();
    void lazyInitComplete();
    void locationsFound(QVariant const& locations);
    void requestComplete();
    void transferProgress(QVariant const& cookie, qint64 bytesSent, qint64 bytesTotal);
    void textualChange();
    void titleFound(QString const& title);
    void userFound(QVariant const& user);

private slots:
    void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
    void invoked(bb::system::InvokeRequest const& request);
    void lazyInit();
    void onCompressed();
    void onDirectoryChanged(QString const& path);
    void onFileChanged(QString const& path);
    void onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error);
    void onSettingChanged(QString const& key);

public:
    ApplicationUI(bb::system::InvokeManager* im);
    virtual ~ApplicationUI() {}

    Q_SLOT void createContacts(QString const& filePath);
    Q_SLOT void compressIlmDatabase(bool notifyClients=false);
    Q_INVOKABLE void doDiff(QVariantList const& input, bb::cascades::ArrayDataModel* adm, QString const& key="id");
    Q_INVOKABLE void loadIlmDatabase(bool force=false);
    Q_INVOKABLE QString databasePath();
    Q_INVOKABLE void geoLookup(QString const& location);
    Q_INVOKABLE void geoLookup(qreal latitude, qreal longitude);
    Q_INVOKABLE void fetchAllIds(QObject* caller, QString const& table);
    Q_INVOKABLE void lookupUser(QString const& address, bool userId=false);
    Q_INVOKABLE void setIndexAsId(QObject* caller, QVariantList const& q, QVariantList const& intersection=QVariantList());
    Q_INVOKABLE void createContactCard(QString const& name, QStringList const& whatsapp, QStringList const& bbm);
    Q_INVOKABLE void uploadChats();
};

}

#endif /* ApplicationUI_HPP_ */
