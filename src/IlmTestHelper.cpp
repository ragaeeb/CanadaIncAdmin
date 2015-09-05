#include "precompiled.h"

#include "IlmTestHelper.h"
#include "DatabaseHelper.h"
#include "QueryId.h"

namespace ilmtest {

using namespace admin;
using namespace canadainc;

IlmTestHelper::IlmTestHelper(DatabaseHelper* sql) : m_sql(sql)
{
}

void IlmTestHelper::lazyInit()
{
}


void IlmTestHelper::fetchQuestionsForSuitePage(QObject* caller, qint64 suitePageId)
{
    QStringList fields = QStringList() << "id" << "standard_body" << "ordered_body" << "count_body" << "after_body" << "before_body" << "difficulty" << "source_id";
    m_sql->executeQuery(caller, QString("SELECT %1 FROM questions WHERE suite_page_id=%2").arg( fields.join(",") ).arg(suitePageId), QueryId::FetchQuestionsForSuitePage);
}


IlmTestHelper::~IlmTestHelper()
{
}

} /* namespace ilmtest */
