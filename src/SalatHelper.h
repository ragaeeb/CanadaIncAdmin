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
    Q_INVOKABLE void fetchTagsForSuitePage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void removeTag(QObject* caller, qint64 id, QString const& table="grouped_suite_pages");
    Q_INVOKABLE void searchTags(QObject* caller, QString const& term=QString());
    Q_INVOKABLE QVariantMap tagSuitePage(qint64 const& suitePageId, int tag);
    Q_INVOKABLE QVariantMap createTag(QString const& name);

    void lazyInit();
};

} /* namespace ilm */

#endif /* SALATHELPER_H_ */
