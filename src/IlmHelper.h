#ifndef ILMHELPER_H_
#define ILMHELPER_H_

#include <QObject>

namespace canadainc {
    class DatabaseHelper;
}

namespace ilm {

using namespace canadainc;

class IlmHelper : public QObject
{
    Q_OBJECT

    DatabaseHelper* m_sql;
    QString m_name;

public:
    IlmHelper(DatabaseHelper* sql);
    virtual ~IlmHelper();

    Q_INVOKABLE QVariantMap addLocation(QString const& city, qreal latitude, qreal longitude);
    Q_INVOKABLE QVariantMap addIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description);
    Q_INVOKABLE QVariantMap addRelation(qint64 individual, qint64 other, int type);
    Q_INVOKABLE QVariantMap editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description);
    Q_INVOKABLE void addMention(QObject* caller, qint64 suitePageId, QVariantList const& targetIds, QVariant const& points);
    Q_INVOKABLE QVariantMap addWebsite(qint64 individualId, QString const& address);
    Q_INVOKABLE QVariantMap editMention(QObject* caller, qint64 id, QVariant const& points);
    Q_INVOKABLE QVariantMap editLocation(QObject* caller, qint64 id, QString const& city);
    Q_INVOKABLE void fetchAllIndividuals(QObject* caller, bool companionsOnly=false, QVariant const& knownLocations=QVariant());
    Q_INVOKABLE void fetchAllLocations(QObject* caller, QString const& city=QString());
    Q_INVOKABLE void fetchAllWebsites(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchMentions(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchBioMetadata(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchFrequentIndividuals(QObject* caller, QString const& table="suites", QString const& field="author", int n=7, QString const& where=QString());
    Q_INVOKABLE void fetchIndividualData(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchRelations(QObject* caller, qint64 individual);
    Q_INVOKABLE void removeMention(QObject* caller, qint64 id);
    Q_INVOKABLE void removeIndividual(QObject* caller, qint64 id);
    Q_INVOKABLE void removeLocation(QObject* caller, qint64 id);
    Q_INVOKABLE void removeRelation(QObject* caller, qint64 id);
    Q_INVOKABLE void removeWebsite(QObject* caller, qint64 id);
    Q_INVOKABLE void replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId);
    Q_INVOKABLE void searchIndividuals(QObject* caller, QVariantList const& terms, QVariantList const& exclusions=QVariantList());
    Q_INVOKABLE void searchIndividualsByDeath(QObject* caller, int death, QVariantList const& exclusions=QVariantList());

    void lazyInit();
    void setDatabaseName(QString const& name);
    QString databaseName() const;
};

} /* namespace ilm */

#endif /* ILMHELPER_H_ */
