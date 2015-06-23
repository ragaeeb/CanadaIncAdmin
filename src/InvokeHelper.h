#ifndef INVOKEHELPER_H_
#define INVOKEHELPER_H_

#include <bb/system/InvokeRequest>

#include "TextUtils.h"

namespace bb {
    namespace system {
        class InvokeManager;
    }
}

namespace ilm {
    class IlmHelper;
}

namespace admin {

using namespace ilm;
using namespace bb::system;

class InvokeHelper : public QObject
{
    Q_OBJECT

    bb::system::InvokeRequest m_request;
    QObject* m_root;
    InvokeManager* m_invokeManager;
    IlmHelper* m_ilm;
    canadainc::TextUtils m_textUtils;

private slots:
    void onDataLoaded(QVariant id, QVariant data);
    void onEditIndividual(QVariant id, QString prefix, QString name, QString kunya, QString displayName, bool hidden, int birth, int death, bool female, QVariant location, bool companion);

public:
    InvokeHelper(InvokeManager* invokeManager, IlmHelper* ilm);
    virtual ~InvokeHelper();

    void init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent);
    QString invoked(bb::system::InvokeRequest const& request);
    void process();
};

} /* namespace admin */

#endif /* INVOKEHELPER_H_ */
