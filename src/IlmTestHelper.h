#ifndef ILMTESTHELPER_H_
#define ILMTESTHELPER_H_

#include <QObject>

namespace canadainc {
    class DatabaseHelper;
}

namespace ilmtest {

using namespace canadainc;

class IlmTestHelper : public QObject
{
    DatabaseHelper* m_sql;

public:
    IlmTestHelper(DatabaseHelper* sql);
    virtual ~IlmTestHelper();

    Q_INVOKABLE void fetchQuestionsForSuitePage(QObject* caller, qint64 suitePageId);

    void lazyInit();
};

} /* namespace ilmtest */

#endif /* ILMTESTHELPER_H_ */
