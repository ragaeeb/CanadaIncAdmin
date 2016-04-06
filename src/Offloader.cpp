#include "precompiled.h"

#include "Offloader.h"
#include "Logger.h"
#include "QueryId.h"
#include "SimilarUtils.h"
#include "TextUtils.h"

#define ATTRIBUTE_TYPE_BIO "bio"
#define KEY_ATTRIBUTE_TYPE "type"
#define KEY_DEATH "death"
#define KEY_KUNYA "kunya"
#define KEY_NAME "name"
#define KEY_PREFIX "prefix"

namespace admin {

using namespace canadainc;
using namespace islamiclib;

Offloader::Offloader()
{
}


QVariantList Offloader::decorateWebsites(QVariantList input)
{
    for (int i = input.size()-1; i >= 0; i--)
    {
        QVariantMap q = input[i].toMap();
        QString uri = q.value("uri").toString();

        if ( TextUtils::isUrl(uri) )
        {
            q["type"] = "website";

            if ( uri.contains("wordpress.com") ) {
                uri = "images/list/site_wordpress.png";
            } else if ( uri.contains("twitter.com") ) {
                uri = "images/list/site_twitter.png";
            } else if ( uri.contains("tumblr.com") ) {
                uri = "images/list/site_tumblr.png";
            } else if ( uri.contains("facebook.com") ) {
                uri = "images/list/site_facebook.png";
            } else if ( uri.contains("soundcloud.com") ) {
                uri = "images/list/site_soundcloud.png";
            } else if ( uri.contains("youtube.com") ) {
                uri = "images/list/site_youtube.png";
            } else if ( uri.contains("linkedin.com") ) {
                uri = "images/list/site_linkedin.png";
            } else {
                uri = "images/list/site_link.png";
            }

            q["imageSource"] = uri;
        } else if ( TextUtils::isEmail(uri) ) {
            q["type"] = "email";
        } else if ( TextUtils::isPhoneNumber(uri) ) {
            q["type"] = "phone";
        }

        input[i] = q;
    }

    return input;
}


QVariantList Offloader::fillType(QVariantList input, int queryId)
{
    QMap<int,QString> map;
    map[QueryId::FetchBio] = ATTRIBUTE_TYPE_BIO;
    map[QueryId::FetchTeachers] = "teacher";
    map[QueryId::FetchStudents] = "student";
    map[QueryId::FetchParents] = "parent";
    map[QueryId::FetchSiblings] = "sibling";
    map[QueryId::FetchChildren] = "child";
    map[QueryId::FetchAllWebsites] = "website";
    map[QueryId::FetchBooksForAuthor] = "book";

    if (queryId == QueryId::FetchAllWebsites) {
        input = decorateWebsites(input);
    }

    if ( map.contains(queryId) )
    {
        QString type = map.value(queryId);

        for (int i = input.size()-1; i >= 0; i--)
        {
            QVariantMap q = input[i].toMap();

            if ( !q.contains(KEY_ATTRIBUTE_TYPE) )
            {
                if ( type == ATTRIBUTE_TYPE_BIO && q.value("points").toInt() == 2 ) {
                    q[KEY_ATTRIBUTE_TYPE] = "citing";
                } else {
                    q[KEY_ATTRIBUTE_TYPE] = type;
                }

                input[i] = q;
            }
        }

        return input;
    }

    return QVariantList();
}


QString Offloader::toTitleCase(QString const& s)
{
    static const QString matchWords = QString("\\b([\\w'%1%2]+)\\b").arg( QChar(8217) ).arg( QChar(8216) );
    static const QString littleWords = "\\b(a|an|and|as|at|by|for|if|in|of|on|or|to|the|ibn|bin|bint|b\\.)\\b";
    QString result = s.toLower();

    QRegExp wordRegExp(matchWords);
    int i = wordRegExp.indexIn( result );
    QString match = wordRegExp.cap(1);
    bool first = true;

    QRegExp littleWordRegExp(littleWords);
    while (i > -1)
    {
        if ( match == match.toLower() && ( first || !littleWordRegExp.exactMatch( match ) ) )
        {
            result[i] = result[i].toUpper();
        }

        i = wordRegExp.indexIn( result, i + match.length() );
        match = wordRegExp.cap(1);
        first = false;
    }

    return result;
}


QVariantMap Offloader::parseName(QString const& n)
{
    if ( m_prefixes.isEmpty() )
    {
        QStringList prefixes = QStringList() << "Shaykh-ul" << "ash-Shaykh" << "ash-Sheikh" << "Dr." << "Doctor" << "Shaykh" << "Sheikh" << "Shaikh" << "Imam" << "Imaam" << "Al-Imaam" << "Imâm" << "Imām" << "al-’Allaamah" << "Al-‘Allaamah" << "Al-Allaamah" << "Al-Allamah" << "Al-Allama" << "Al-Allaama" << "Allaama" << "Muhaddith" << "Al-Haafidh" << "Al-Hafith" << "Al-Hafidh" << "Al-Haafidh" << "Hafidh" << "Ustadh" << "Prince" << "King" << "al-Faqeeh" << "al-Faqih";

        foreach (QString const& p, prefixes) {
            m_prefixes << p.toLower();
        }
    }

    if ( m_kunyas.isEmpty() )
    {
        QStringList kunyas = QStringList() << "Abu" << "Aboo";

        foreach (QString const& p, kunyas) {
            m_kunyas << p.toLower();
        }
    }

    QStringList prefix;
    QStringList kunya;
    int death = 0;
    QStringList all = n.split(" ");
    QVariantMap result;

    if ( all.size() > 1 )
    {
        QString last = all.last().toLower();
        QString secondLast = all.at( all.size()-2 ).toLower();

        if ( QRegExp("[\\(\\[]{0,1}died|[\\(\\[]{0,1}d\\.{0,1}$").exactMatch(secondLast) )
        {
            last.remove( QRegExp("\\D") ); // remove all non numeric values
            death = last.toInt();

            if (death > 0)
            {
                all.takeLast();
                all.takeLast();
            }
        }
    }

    while ( !all.isEmpty() )
    {
        QString current = all.first();

        if ( m_prefixes.contains( current.toLower() ) ) {
            prefix << all.takeFirst();
        } else if ( m_kunyas.contains( current.toLower() ) ) {
            kunya << all.takeFirst() << all.takeFirst(); // take the abu as well as the next word

            if ( !all.isEmpty() )
            {
                QString next = all.first().toLower();

                if (next == "abdur" || next == "abdul" || next == "abdi") { // it's part of a two-word kunya
                    kunya << all.takeFirst();
                }
            }
        } else {
            break;
        }
    }

    if ( all.isEmpty() && !kunya.isEmpty() ) // if there was only a kunya
    {
        all = kunya;
        kunya.clear();
    }

    if ( !kunya.isEmpty() ) {
        result[KEY_KUNYA] = kunya.join(" ");
    }

    if ( !prefix.isEmpty() ) {
        result[KEY_PREFIX] = prefix.join(" ");
    }

    if ( !all.isEmpty() ) {
        result[KEY_NAME] = all.join(" ");
    }

    if (death > 0) {
        result[KEY_DEATH] = death;
    }

    return result;
}


void Offloader::onResultsDecorated()
{
    QFutureWatcher<SimilarReference>* qfw = static_cast< QFutureWatcher<SimilarReference>* >( sender() );
    SimilarUtils::onResultsDecorated( qfw->result() );

    SimilarReference sr = qfw->result();
    bb::cascades::ArrayDataModel* adm = sr.adm;

    sender()->deleteLater();
}


void Offloader::decorateSearchResults(QVariantList const& input, bb::cascades::ArrayDataModel* adm, QVariantList const& queries)
{
    LOGGER(input.size() << queries);

    QFutureWatcher<SimilarReference>* qfw = new QFutureWatcher<SimilarReference>(this);
    connect( qfw, SIGNAL( finished() ), this, SLOT( onResultsDecorated() ) );

    QFuture<SimilarReference> future = QtConcurrent::run(&SimilarUtils::decorateResults, input, adm, queries);
    qfw->setFuture(future);
}


Offloader::~Offloader()
{
}

} /* namespace quran */
