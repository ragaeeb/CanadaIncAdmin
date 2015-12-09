#ifndef SALATHELPER_H_
#define SALATHELPER_H_

#include <QObject>
#include <QVariant>

namespace canadainc {
    class DatabaseHelper;
}

namespace admin {

using namespace canadainc;

class SalatHelper : public QObject
{
    Q_OBJECT

    DatabaseHelper* m_sql;

public:
    SalatHelper(DatabaseHelper* sql);
    virtual ~SalatHelper();

    Q_INVOKABLE QVariantMap addCenter(QString const& name, QString const& website, qint64 location);
    Q_INVOKABLE QVariantMap editCenter(QObject* caller, qint64 id, QString const& name, QString const& website, qint64 location);
    Q_INVOKABLE void fetchAllCenters(QObject* caller, QString const& name=QString());
    Q_INVOKABLE void fetchCenter(QObject* caller, qint64 id);

    void lazyInit();
};

} /* namespace ilm */

#endif /* SALATHELPER_H_ */
