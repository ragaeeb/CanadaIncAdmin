#ifndef PRIMARYTABLE_H_
#define PRIMARYTABLE_H_

#include <QObject>
#include <QString>

namespace canadainc {
    class DatabaseHelper;
}

namespace admin {

class PrimaryTable : public QObject
{
    Q_OBJECT

    canadainc::DatabaseHelper* m_db;
    QString m_table;

public:
    PrimaryTable(canadainc::DatabaseHelper* db, QString const& table);
    virtual ~PrimaryTable();

    Q_INVOKABLE QVariantMap create(QObject* caller, QVariantMap const& data);
    Q_INVOKABLE void remove(QObject* caller, qint64 id);
    Q_INVOKABLE void getAllLinks(QObject* caller, qint64 pageId);
};

} /* namespace admin */

#endif /* PRIMARYTABLE_H_ */
