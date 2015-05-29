#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include "DatabaseHelper.h"
#include "Persistance.h"

namespace admin {

using namespace canadainc;

class ApplicationUI : public QObject
{
    Q_OBJECT

    DatabaseHelper m_sql;
    Persistance m_persistance;

public:
    ApplicationUI();
    virtual ~ApplicationUI() {}
};

}

#endif /* ApplicationUI_HPP_ */
