#ifndef PAGELINKTABLE_H_
#define PAGELINKTABLE_H_

#include <QObject>
#include <QString>

namespace canadainc {
    class DatabaseHelper;
}

namespace admin {

class PageLinkTable : public QObject
{
    Q_OBJECT

    canadainc::DatabaseHelper* m_db;
    QString m_table;

public:
    PageLinkTable(canadainc::DatabaseHelper* db, QString const& table);
    virtual ~PageLinkTable();

    Q_INVOKABLE QVariantMap createLink(QObject* caller, qint64 id, qint64 pageId, qint64 refTableId, int linkType=0, QVariantMap fields=QVariantMap());
    Q_INVOKABLE void deleteLink(QObject* caller, qint64 id);
    Q_INVOKABLE void getAllLinks(QObject* caller, qint64 pageId);
};

} /* namespace admin */

#endif /* PageLinkTable */
