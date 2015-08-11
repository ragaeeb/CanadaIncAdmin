#include "precompiled.h"

#include "InvokeHelper.h"
#include "CardUtils.h"
#include "Logger.h"
#include "QueryId.h"

namespace admin {

using namespace bb::system;
using namespace canadainc;

InvokeHelper::InvokeHelper(InvokeManager* invokeManager) :
        m_root(NULL), m_invokeManager(invokeManager)
{
}


void InvokeHelper::init(QString const& qmlDoc, QMap<QString, QObject*> const& context, QObject* parent)
{
    qmlRegisterUncreatableType<QueryId>("com.canadainc.data", 1, 0, "QueryId", "Can't instantiate");

    QmlDocument* qml = QmlDocument::create("asset:///GlobalProperties.qml").parent(this);
    qml->setContextProperty("textUtils", &m_textUtils);
    QObject* global = qml->createRootObject<QObject>();
    QmlDocument::defaultDeclarativeEngine()->rootContext()->setContextProperty("global", global);

    m_root = CardUtils::initAppropriate(qmlDoc, context, parent);
}


QString InvokeHelper::invoked(bb::system::InvokeRequest const& request)
{
    LOGGER( request.action() << request.target() << request.mimeType() << request.metadata() << request.uri().toString() << QString( request.data() ) );

    QString target = request.target();

    QMap<QString,QString> targetToQML;
    //targetToQML[TARGET_EDIT_INDIVIDUAL] = "CreateIndividualPage.qml";

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
    }
}


InvokeHelper::~InvokeHelper()
{
}

} /* namespace admin */
