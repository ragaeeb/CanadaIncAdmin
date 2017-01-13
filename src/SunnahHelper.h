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

    Q_INVOKABLE void addTypos(QStringList const& queries, qint64 id, QString const& table="narrations");
	Q_INVOKABLE void fetchAllCollections(QObject* caller, QString const& query=QString());
    Q_INVOKABLE void fetchExplanationsFor(QObject* caller, qint64 narrationId);
    Q_INVOKABLE void fetchCorrections(QObject* caller, QString const& table, QString const& query);
    Q_INVOKABLE void fetchGroupsForNarration(QObject* caller, qint64 narrationId);

	/**
	 * @param terms Should be a QVariantList of QVariantMaps with {'collection_id': qint64 CollectionID, 'hadith_number': QString HadithNumber}
	 */
	Q_INVOKABLE void fetchNarration(QObject* caller, QVariantList const& terms);
	Q_INVOKABLE void fetchNarrations(QObject* caller, QVariantList narrationIds);
	Q_INVOKABLE void fetchNarrationsInGroup(QObject* caller, int groupNumber);
    Q_INVOKABLE void fetchNarrationsForSuitePage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchNextAvailableGroupNumber(QObject* caller);
    Q_INVOKABLE void fetchSimilarNarrations(QObject* caller, QVariantList const& ids);
    Q_INVOKABLE void fetchGroupedNarrations(QObject* caller, QVariantList const& ids=QVariantList());
    Q_INVOKABLE void groupNarrations(QObject* caller, QVariantList const& arabicIds, qint64 groupNumber);
    Q_INVOKABLE void linkNarrationsToSuitePage(QObject* caller, qint64 suitePageId, QVariantList const& arabicIds);
    Q_INVOKABLE void reportTypo(QObject* caller, qint64 narrationId, int cursorStart, int cursorEnd);
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
