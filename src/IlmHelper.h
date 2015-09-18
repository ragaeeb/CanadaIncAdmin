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
    Q_INVOKABLE QVariantMap editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description);
    Q_INVOKABLE void addBioLink(QObject* caller, qint64 suitePageId, QVariantList const& targetIds, QVariant const& points);
    Q_INVOKABLE QVariantMap addBook(qint64 author, QString const& title);
    Q_INVOKABLE void addChild(QObject* caller, qint64 parentId, qint64 childId);
    Q_INVOKABLE void addParent(QObject* caller, qint64 childId, qint64 parentId);
    Q_INVOKABLE void addSibling(QObject* caller, qint64 childId, qint64 siblingId);
    Q_INVOKABLE void addStudent(QObject* caller, qint64 teacherId, qint64 studentId);
    Q_INVOKABLE void addTeacher(QObject* caller, qint64 studentId, qint64 teacherId);
    Q_INVOKABLE QVariantMap addWebsite(qint64 individualId, QString const& address);
    Q_INVOKABLE QVariantMap editBioLink(QObject* caller, qint64 id, QVariant const& points);
    Q_INVOKABLE QVariantMap editLocation(QObject* caller, qint64 id, QString const& city);
    Q_INVOKABLE void fetchAllIndividuals(QObject* caller, bool companionsOnly=false, QVariant const& knownLocations=QVariant());
    Q_INVOKABLE void fetchAllLocations(QObject* caller, QString const& city=QString());
    Q_INVOKABLE void fetchAllWebsites(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchBio(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchBooksForAuthor(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchBioMetadata(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchChildren(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchFrequentIndividuals(QObject* caller, QString const& table="suites", QString const& field="author", int n=7);
    Q_INVOKABLE void fetchIndividualData(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchParents(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchSiblings(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchStudents(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchTeachers(QObject* caller, qint64 individualId);
    Q_INVOKABLE void portIndividuals(QObject* caller, QString destinationLanguage="arabic");
    Q_INVOKABLE void removeBioLink(QObject* caller, qint64 id);
    Q_INVOKABLE void removeBook(QObject* caller, qint64 id);
    Q_INVOKABLE void removeChild(QObject* caller, qint64 individual, qint64 parentId);
    Q_INVOKABLE void removeIndividual(QObject* caller, qint64 id);
    Q_INVOKABLE void removeLocation(QObject* caller, qint64 id);
    Q_INVOKABLE void removeParent(QObject* caller, qint64 individual, qint64 parentId);
    Q_INVOKABLE void removeSibling(QObject* caller, qint64 individual, qint64 siblingId);
    Q_INVOKABLE void removeStudent(QObject* caller, qint64 individual, qint64 studentId);
    Q_INVOKABLE void removeTeacher(QObject* caller, qint64 individual, qint64 teacherId);
    Q_INVOKABLE void removeWebsite(QObject* caller, qint64 id);
    Q_INVOKABLE void replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId);
    Q_INVOKABLE void searchIndividuals(QObject* caller, QString const& trimmedText, QString const& andConstraint=QString(), bool startsWith=false);

    void lazyInit();
    void setDatabaseName(QString const& name);
    QString databaseName() const;
};

} /* namespace ilm */

#endif /* ILMHELPER_H_ */
