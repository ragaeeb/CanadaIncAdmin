#ifndef ILMHELPER_H_
#define ILMHELPER_H_

#include <QObject>

#define QURAN_TAFSIR_FILE(lang) QString("quran_tafsir_%1").arg(lang)

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
    QSet<QString> m_prefixes;
    QSet<QString> m_kunyas;

    qint64 generateIndividualField(QObject* caller, QString const& value);

public:
    IlmHelper(DatabaseHelper* sql);
    virtual ~IlmHelper();

    Q_INVOKABLE void addBioLink(QObject* caller, qint64 suitePageId, QVariantList const& targetIds, QVariant const& points);
    Q_INVOKABLE qint64 addLocation(QObject* caller, QString const& city, qreal latitude, qreal longitude);
    Q_INVOKABLE void addQuote(QObject* caller, QString const& author, QString const& body, QString const& reference, QString const& suiteId, QString const& uri);
    Q_INVOKABLE void addParent(QObject* caller, qint64 childId, qint64 parentId);
    Q_INVOKABLE void addSibling(QObject* caller, qint64 childId, qint64 siblingId);
    Q_INVOKABLE void addStudent(QObject* caller, qint64 teacherId, qint64 studentId);
    Q_INVOKABLE void addChild(QObject* caller, qint64 parentId, qint64 childId);
    Q_INVOKABLE void addTafsir(QObject* caller, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE qint64 addTafsirPage(QObject* caller, qint64 suiteId, QString const& body, QString const& heading, QString const& reference);
    Q_INVOKABLE void addTeacher(QObject* caller, qint64 studentId, qint64 teacherId);
    Q_INVOKABLE void addWebsite(QObject* caller, qint64 individualId, QString const& address);
    Q_INVOKABLE qint64 createIndividual(QObject* caller, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, bool companion);
    Q_INVOKABLE void editBioLink(QObject* caller, qint64 id, QVariant const& points);
    Q_INVOKABLE void editIndividual(QObject* caller, qint64 id, QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, bool companion);
    Q_INVOKABLE void editLocation(QObject* caller, qint64 id, QString const& city);
    Q_INVOKABLE void editQuote(QObject* caller, qint64 quoteId, QString const& author, QString const& body, QString const& reference, QString const& suiteId, QString const& uri);
    Q_INVOKABLE void editTafsir(QObject* caller, qint64 suiteId, QString const& author, QString const& translator, QString const& explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE void editTafsirPage(QObject* caller, qint64 suitePageId, QString const& body, QString const& heading, QString const& reference);
    Q_INVOKABLE void fetchAllIndividuals(QObject* caller, bool companionsOnly=false, bool orderByDeath=false);
    Q_INVOKABLE void fetchAllLocations(QObject* caller, QString const& city=QString());
    Q_INVOKABLE void fetchAllWebsites(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchBioMetadata(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchAllQuotes(QObject* caller, qint64 individualId=0);
    Q_INVOKABLE void fetchAllTafsir(QObject* caller, qint64 individualId=0);
    Q_INVOKABLE void fetchAllTafsirForSuite(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchBio(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void fetchTafsirContent(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void findDuplicateQuotes(QObject* caller, QString const& field);
    Q_INVOKABLE void fetchFrequentIndividuals(QObject* caller, QString const& table="suites", QString const& field="author", int n=7);
    Q_INVOKABLE void fetchIndividualData(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchStudents(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchChildren(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchTafsirMetadata(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchSiblings(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchParents(QObject* caller, qint64 individualId);
    Q_INVOKABLE void fetchTeachers(QObject* caller, qint64 individualId);
    Q_INVOKABLE void findDuplicateSuites(QObject* caller, QString const& field);
    Q_INVOKABLE void mergeSuites(QObject* caller, QVariantList const& toReplaceIds, qint64 actualId);
    Q_INVOKABLE void moveToSuite(QObject* caller, qint64 suitePageId, qint64 destSuiteId);
    Q_INVOKABLE QVariantMap parseName(QString n);
    Q_INVOKABLE void portIndividuals(QObject* caller, QString destinationLanguage="arabic");
    Q_INVOKABLE void removeBioLink(QObject* caller, qint64 id);
    Q_INVOKABLE void removeIndividual(QObject* caller, qint64 id);
    Q_INVOKABLE void removeLocation(QObject* caller, qint64 id);
    Q_INVOKABLE void removeQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void removeStudent(QObject* caller, qint64 individual, qint64 studentId);
    Q_INVOKABLE void removeChild(QObject* caller, qint64 individual, qint64 parentId);
    Q_INVOKABLE void removeTafsir(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void removeTafsirPage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void removeTeacher(QObject* caller, qint64 individual, qint64 teacherId);
    Q_INVOKABLE void removeSibling(QObject* caller, qint64 individual, qint64 siblingId);
    Q_INVOKABLE void removeParent(QObject* caller, qint64 individual, qint64 parentId);
    Q_INVOKABLE void removeWebsite(QObject* caller, qint64 id);
    Q_INVOKABLE void replaceIndividual(QObject* caller, qint64 toReplaceId, qint64 actualId);
    Q_INVOKABLE void searchIndividuals(QObject* caller, QString const& trimmedText, QString const& andConstraint=QString());
    Q_INVOKABLE void searchQuote(QObject* caller, QString fieldName, QString const& searchTerm);
    Q_INVOKABLE void searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm);
    Q_INVOKABLE void translateQuote(QObject* caller, qint64 quoteId, QString destinationLanguage="arabic");
    Q_INVOKABLE void translateSuitePage(QObject* caller, qint64 suitePageId, QString destinationLanguage="arabic");

    void lazyInit();
    static QStringList setupTableStatements();
    void setDatabaseName(QString const& name);
    QString databaseName() const;
};

} /* namespace ilm */

#endif /* ILMHELPER_H_ */
