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

class InvokeHelper : public QObject
{
    Q_OBJECT

    canadainc::DeviceUtils m_deviceUtils;
    bb::system::InvokeRequest m_request;
    QObject* m_root;
    InvokeManager* m_invokeManager;
    canadainc::TextUtils m_textUtils;

public:
    InvokeHelper(InvokeManager* invokeManager);
    virtual ~InvokeHelper();

    void init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent);
    QString invoked(bb::system::InvokeRequest const& request);
    void process();
};

} /* namespace admin */

#endif /* INVOKEHELPER_H_ */
