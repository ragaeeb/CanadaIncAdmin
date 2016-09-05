#ifndef TAFSIRHELPER_H_
#define TAFSIRHELPER_H_

#include <QObject>

namespace canadainc {
    class DatabaseHelper;
}

namespace admin {

using namespace canadainc;

class TafsirHelper : public QObject
{
    Q_OBJECT

    DatabaseHelper* m_sql;
    QString m_name;

public:
    TafsirHelper(DatabaseHelper* sql);
    virtual ~TafsirHelper();

    Q_INVOKABLE QVariantMap addQuote(qint64 author, qint64 translator, QString const& body, QString const& reference, qint64 suiteId, QString const& uri);
    Q_INVOKABLE QVariantMap addSuite(qint64 author, qint64 translator, qint64 explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE QVariantMap addSuitePage(qint64 suiteId, QString const& body, QString const& heading, QString const& reference);
    Q_INVOKABLE QVariantMap editQuote(QObject* caller, qint64 quoteId, qint64 author, qint64 translator, QString const& body, QString const& reference, qint64 suiteId, QString const& uri);
    Q_INVOKABLE QVariantMap editSuite(QObject* caller, qint64 id, qint64 author, qint64 translator, qint64 explainer, QString const& title, QString const& description, QString const& reference);
    Q_INVOKABLE QVariantMap editSuitePage(QObject* caller, qint64 suitePageId, QString const& body, QString const& heading, QString const& reference);
    Q_INVOKABLE void fetchAllQuotes(QObject* caller, qint64 id=0, qint64 author=0, int limit=200);
    Q_INVOKABLE void fetchAllTafsir(QObject* caller, qint64 id=0);
    Q_INVOKABLE void fetchAllTafsirForSuite(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void fetchTafsirContent(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void fetchTafsirMetadata(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void fetchSuitePageIntersection(QObject* caller, QString other="arabic");
    Q_INVOKABLE void findDuplicateQuotes(QObject* caller, QString const& field);
    Q_INVOKABLE void findDuplicateSuites(QObject* caller, QString const& field);
    Q_INVOKABLE void mergeSuites(QObject* caller, QVariantList const& toReplaceIds, qint64 actualId);
    Q_INVOKABLE void moveToSuite(QObject* caller, qint64 suitePageId, qint64 destSuiteId);
    Q_INVOKABLE void removeQuote(QObject* caller, qint64 id);
    Q_INVOKABLE void removeSuite(QObject* caller, qint64 suiteId);
    Q_INVOKABLE void removeSuitePage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void searchQuote(QObject* caller, QString fieldName, QString const& searchTerm);
    Q_INVOKABLE void searchTafsir(QObject* caller, QString const& fieldName, QString const& searchTerm);
    Q_INVOKABLE void translateQuote(QObject* caller, qint64 quoteId, QString destinationLanguage="arabic");
    Q_INVOKABLE void translateSuitePage(QObject* caller, qint64 suitePageId, QString destinationLanguage="arabic");

    void lazyInit();
    void setDatabaseName(QString const& name);
    QString databaseName() const;
};

} /* namespace admin */

#endif /* TAFSIRHELPER_H_ */
