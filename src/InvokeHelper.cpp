#include "precompiled.h"

#include "InvokeHelper.h"
#include "CardUtils.h"
#include "DeviceUtils.h"
#include "IlmHelper.h"
#include "Logger.h"
#include "QueryId.h"

#define TARGET_EDIT_INDIVIDUAL "com.canadainc.CanadaIncAdmin.editIndividual"

namespace admin {

using namespace bb::system;
using namespace canadainc;
using namespace ilm;

InvokeHelper::InvokeHelper(InvokeManager* invokeManager, IlmHelper* ilm) :
        m_root(NULL), m_invokeManager(invokeManager), m_ilm(ilm)
{
}


void InvokeHelper::onDataLoaded(QVariant id, QVariant data)
{
    Q_UNUSED(data);

    if ( id.toLongLong() == QueryId::EditIndividual ) {
        m_invokeManager->sendCardDone( CardDoneMessage() );
    }
}


void InvokeHelper::onEditIndividual(QVariant id, QString prefix, QString name, QString kunya, QString displayName, bool hidden, int birth, int death, bool female, QVariant location, bool companion)
{
    m_ilm->editIndividual( this, id.toLongLong(), prefix, name, kunya, displayName, hidden, birth, death, female, location.toString(), companion );
}


void InvokeHelper::init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent)
{
    qmlRegisterUncreatableType<QueryId>("com.canadainc.data", 1, 0, "QueryId", "Can't instantiate");

    DeviceUtils::create(this);

    m_root = CardUtils::initAppropriate(qmlDoc, context, parent);
}


QString InvokeHelper::invoked(bb::system::InvokeRequest const& request)
{
    LOGGER( request.action() << request.target() << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QString target = request.target();

    QMap<QString,QString> targetToQML;
    targetToQML[TARGET_EDIT_INDIVIDUAL] = "CreateIndividualPage.qml";

    QString qml = targetToQML.value(target);

    if ( qml.isNull() ) {
        qml = "CardPage.qml";
    }

    m_request = request;
    m_request.setTarget(target);

    return qml;
}


void InvokeHelper::process()
{
    QString target = m_request.target();

    if ( !target.isEmpty() )
    {
        QString src = QString( m_request.data() );

        if (target == TARGET_EDIT_INDIVIDUAL)
        {
            m_root->setProperty( "individualId", src.toLongLong() );
            connect( m_root, SIGNAL( createIndividual(QVariant, QString, QString, QString, QString, bool, int, int, bool, QVariant, bool) ), this, SLOT( onEditIndividual(QVariant, QString, QString, QString, QString, bool, int, int, bool, QVariant, bool) ) );
        }
    }
}


InvokeHelper::~InvokeHelper()
{
}

} /* namespace admin */
