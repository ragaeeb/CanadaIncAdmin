    #ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "DatabaseHelper.h"
#include "IlmHelper.h"
#include "NetworkProcessor.h"
#include "Persistance.h"
#include "QuranHelper.h"

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
    bb::system::InvokeRequest m_request;
    QObject* m_root;
    ilm::IlmHelper m_ilm;
    quran::QuranHelper m_quran;
    QFileSystemWatcher m_watcher;
    QFile m_source;
    QFile m_target;

    void init(QString const& qml);
    static void onErrorMessage(const char* msg);

signals:
    void childCardFinished(QString const& message);
    void compressed(bool success);
    void compressProgress(qint64 current, qint64 total);
    void compressing();
    void initialize();
    void lazyInitComplete();
    void requestComplete();
    void transferProgress(QVariant const& cookie, qint64 bytesSent, qint64 bytesTotal);
    void textualChange();

private slots:
    void childCardDone(bb::system::CardDoneMessage const& message=bb::system::CardDoneMessage());
    void invoked(bb::system::InvokeRequest const& request);
    void lazyInit();
    void onCompressed();
    void onDirectoryChanged(QString const& path);
    void onFileChanged(QString const& path);
    void onRequestComplete(QVariant const& cookie, QByteArray const& data, bool error);

public:
    ApplicationUI();
    virtual ~ApplicationUI() {}

    Q_SLOT void compressIlmDatabase();
    Q_INVOKABLE void doDiff(QVariantList const& input, bb::cascades::ArrayDataModel* adm, QString const& key="id");
    Q_INVOKABLE void loadIlmDatabase();

    QString ilmDatabaseName();
};

}

#endif /* ApplicationUI_HPP_ */
