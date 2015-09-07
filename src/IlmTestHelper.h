#ifndef ILMTESTHELPER_H_
#define ILMTESTHELPER_H_

#include <QObject>
#include <QVariant>

namespace canadainc {
    class DatabaseHelper;
}

namespace ilmtest {

using namespace canadainc;

class IlmTestHelper : public QObject
{
    Q_OBJECT

    DatabaseHelper* m_sql;

public:
    IlmTestHelper(DatabaseHelper* sql);
    virtual ~IlmTestHelper();

    Q_INVOKABLE QVariantMap addQuestion(qint64 suitePageId, QString const& standardBody, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& afterBody, QString const& beforeBody, int difficulty);
    Q_INVOKABLE QVariantMap addAnswer(qint64 questionId, qint64 choiceId, bool correct);
    Q_INVOKABLE QVariantMap addChoice(QString const& value);
    Q_INVOKABLE QVariantMap editChoice(QObject* caller, qint64 id, QString const& value);
    Q_INVOKABLE QVariantMap editQuestion(QObject* caller, qint64 id, QString const& standardBody, QString const& boolStandardBody, QString const& promptStandardBody, QString const& orderedBody, QString const& countBody, QString const& boolCountBody, QString const& promptCountBody, QString const& afterBody, QString const& beforeBody, int difficulty);
    Q_INVOKABLE void fetchAllChoices(QObject* caller, QString const& choice=QString());
    Q_INVOKABLE void fetchQuestion(QObject* caller, qint64 questionId);
    Q_INVOKABLE void fetchChoicesForQuestion(QObject* caller, qint64 questionId);
    Q_INVOKABLE void fetchQuestionsForSuitePage(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void removeAnswer(QObject* caller, qint64 id);
    Q_INVOKABLE void removeChoice(QObject* caller, qint64 id);
    Q_INVOKABLE void removeQuestion(QObject* caller, qint64 id);
    Q_INVOKABLE void updateSortOrders(QObject* caller, QVariantList const& qvl);

    void lazyInit();
};

} /* namespace ilmtest */

#endif /* ILMTESTHELPER_H_ */
