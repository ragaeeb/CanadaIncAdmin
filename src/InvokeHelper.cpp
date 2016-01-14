#include "precompiled.h"

#include "InvokeHelper.h"
#include "CardUtils.h"
#include "Logger.h"
#include "Persistance.h"
#include "QueryId.h"
#include "TafsirHelper.h"
#include "TextUtils.h"

#define REGEX_QUOTES QRegExp("\"([^\"]*)\"")
#define REGEX_SPECIAL_QUOTES QRegExp( QString("([^\"]*)").prepend( QChar(8220) ).append( QChar(8221) ) )
#define REGEX_BRACKETS QRegExp("\\[(.*)\\]")
#define REGEX_URL QRegExp("http[^\\s]+")
#define TARGET_SHARE_QUOTE "com.canadainc.CanadaIncAdmin.createQuote"

namespace {

QString extractQuotes(QString const& str, QRegExp const& regex, bool chop=true)
{
    int pos = 0;
    while ((pos = regex.indexIn(str, pos)) != -1)
    {
        QString x = regex.cap(0);

        //pos += regex.matchedLength();

        return chop ? canadainc::TextUtils::removeBrackets(x) : x.trimmed();
    }

    return QString();
}

}

namespace admin {

using namespace bb::system;
using namespace canadainc;

InvokeHelper::InvokeHelper(InvokeManager* invokeManager, TafsirHelper* tafsir) :
        m_root(NULL), m_invokeManager(invokeManager), m_tafsir(tafsir)
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
    targetToQML[TARGET_SHARE_QUOTE] = "CreateQuotePage.qml";

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
        if (target == TARGET_SHARE_QUOTE)
        {
            QByteArray qba = m_request.data();
            QStringList tokens;
            QStringList unmatched;
            QString url;
            QString quote;
            QString src;

            if ( !m_request.data().isEmpty() ) {
                tokens = QString::fromUtf8( qba.data() ).split("\n");
            } else {
                if ( !m_request.uri().isEmpty() ) {
                    url = m_request.uri().toString();
                }

                QVariantMap data = m_request.metadata();
                tokens = data.value("description").toString().split("\n");
            }

            foreach (QString current, tokens)
            {
                current = current.trimmed();

                if ( !current.isEmpty() )
                {
                    if ( current.contains("twitter.com") && url.isEmpty() )
                    {
                        url = extractQuotes(current, REGEX_URL, false);
                        current.remove(url);
                    }

                    if ( current.contains("\"") )
                    {
                        quote = extractQuotes(current, REGEX_QUOTES);
                        current.remove(quote);
                    }

                    if ( current.contains( QChar(8220) ) )
                    {
                        quote = extractQuotes(current, REGEX_SPECIAL_QUOTES);
                        current.remove(quote);
                    }

                    if ( current.contains("[") )
                    {
                        src = extractQuotes(current, REGEX_BRACKETS);
                        current.remove(src);
                    }

                    current = current.trimmed();

                    if ( !current.isEmpty() ) {
                        unmatched << current;
                    }
                }
            }

            applyProperty("uri", url);
            applyProperty("body", quote);
            applyProperty("reference", src);
            applyProperty("bufferText", unmatched.join("\n"));

            connect( m_root, SIGNAL( createQuote(QVariant, QString, QString, QString, QVariant, QString) ), this, SLOT( createQuote(QVariant, QString, QString, QString, QVariant, QString) ) );
        }
    }
}


void InvokeHelper::createQuote(QVariant id, QString author, QString body, QString reference, QVariant suiteId, QString uri)
{
    Q_UNUSED(id);

    m_tafsir->addQuote( author.toLongLong(), body, reference, suiteId.toLongLong(), uri );

    Persistance::showBlockingDialog( tr("Quote added"), tr("Quote successfully added!"), tr("OK"), "" );
    m_invokeManager->sendCardDone( CardDoneMessage() );
}


void InvokeHelper::applyProperty(const char* field, QString const& value)
{
    if ( !value.isEmpty() ) {
        m_root->setProperty(field, value);
    }
}


InvokeHelper::~InvokeHelper()
{
}

} /* namespace admin */
