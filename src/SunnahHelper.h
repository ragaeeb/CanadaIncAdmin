#ifndef SUNNAHHELPER_H_
#define SUNNAHHELPER_H_

#include "QueryId.h"

#include <QFutureWatcher>
#include <QVariant>

namespace canadainc {
    class DatabaseHelper;
}

namespace sunnah {

using namespace admin;
using namespace canadainc;

class SunnahHelper : public QObject
{
	Q_OBJECT

	DatabaseHelper* m_sql;
	QString m_name;

public:
	SunnahHelper(DatabaseHelper* sql);
	virtual ~SunnahHelper();

	void lazyInit();

	Q_INVOKABLE void fetchAllCollections(QObject* caller);
	Q_INVOKABLE void fetchNarration(QObject* caller, qint64 collectionId, QString const& hadithNumber);
    Q_INVOKABLE void fetchNarrationsForSuitePage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchGroupedNarrations(QObject* caller);
    Q_INVOKABLE void linkNarrations(QObject* caller, QVariantList const& arabicIds);
    Q_INVOKABLE void linkNarrationsToSuitePage(QObject* caller, qint64 suitePageId, QVariantList const& arabicIds);
    Q_INVOKABLE void searchNarrations(QObject* caller, QVariantList const& terms, QVariantList const& collections, bool restrictToShort);
    Q_INVOKABLE void unlinkNarrationsFromSuitePage(QObject* caller, QVariantList const& arabicIds, qint64 suitePageId);
    Q_INVOKABLE void unlinkNarrationFromSimilar(QObject* caller, QVariantList const& data);

    /**
     * @param ids This is the actual primary key (not narration id).
     */
    Q_INVOKABLE void updateGroupNumber(QObject* caller, QVariantList const& ids, qint64 groupNumber);

    void setDatabaseName(QString const& name);
};

} /* namespace sunnah */
#endif /* SUNNAHHELPER_H_ */
