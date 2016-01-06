#ifndef INVOKEHELPER_H_
#define INVOKEHELPER_H_

#include <bb/system/InvokeRequest>

#include "DeviceUtils.h"
#include "TextUtils.h"

namespace bb {
    namespace system {
        class InvokeManager;
    }
}

namespace admin {

using namespace bb::system;

class TafsirHelper;

class InvokeHelper : public QObject
{
    Q_OBJECT

    canadainc::DeviceUtils m_deviceUtils;
    bb::system::InvokeRequest m_request;
    QObject* m_root;
    InvokeManager* m_invokeManager;
    canadainc::TextUtils m_textUtils;
    TafsirHelper* m_tafsir;

    void applyProperty(const char* field, QString const& value);

private slots:
    void createQuote(QVariant id, QString author, QString body, QString reference, QVariant suiteId, QString uri);

public:
    InvokeHelper(InvokeManager* invokeManager, TafsirHelper* tafsir);
    virtual ~InvokeHelper();

    void init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent);
    QString invoked(bb::system::InvokeRequest const& request);
    void process();
};

} /* namespace admin */

#endif /* INVOKEHELPER_H_ */
