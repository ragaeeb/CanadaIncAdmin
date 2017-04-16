#include "precompiled.h"

#include "Offloader.h"
#include "DeviceUtils.h"
#include "Logger.h"
#include "QueryId.h"
#include "SearchDecorator.h"

#define ATTRIBUTE_TYPE_BIO "bio"
#define KEY_ATTRIBUTE_TYPE "type"
#define KEY_DEATH "death"
#define KEY_KUNYA "kunya"
#define KEY_NAME "name"
#define KEY_PREFIX "prefix"
#define KEY_NARRATION_BODY "body"

namespace admin {

using namespace canadainc;

Offloader::Offloader()
{
}


QVariantList Offloader::decorateWebsites(QVariantList input)
{
    for (int i = input.size()-1; i >= 0; i--)
    {
        QVariantMap q = input[i].toMap();
        QString uri = q.value("uri").toString();

        if ( DeviceUtils::isUrl(uri) )
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
        } else if ( DeviceUtils::isValidEmail(uri) ) {
            q["type"] = "email";
        } else if ( DeviceUtils::isValidPhoneNumber(uri) ) {
            q["type"] = "phone";
        }

        input[i] = q;
    }

    return input;
}


QString Offloader::toTitleCase(QString const& s)
{
    QString result = s.toLower();

    QRegExp wordRegExp( QString("\\b([\\w'%1%2]+)\\b").arg( QChar(8217) ).arg( QChar(8216) ) );
    int i = wordRegExp.indexIn( result );
    QString match = wordRegExp.cap(1);
    bool first = true;

    QRegExp littleWordRegExp("\\b(a|an|and|as|at|by|for|if|in|of|on|or|to|the|ibn|bin|bint|b\\.)\\b");
    while (i > -1)
    {
        if ( match == match.toLower() && ( first || !littleWordRegExp.exactMatch( match ) ) ) {
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


int Offloader::diffSecs(QString const& input)
{
    QDateTime then = QDateTime::fromString(input, "yyyy-MM-dd HH:mm:ss");
    QDateTime now = QDateTime::currentDateTime();

    return then.secsTo(now);
}


QString Offloader::extractHost(QString const& uri)
{
    QUrl result(uri);

    if ( result.host() == "twitter.com" ) {
        return QString("%1/%2").arg( result.host() ).arg( result.path().mid(1).split("/").first() );
    } else {
        return result.host();
    }
}


QString Offloader::fixUri(QString const& uri)
{
    QUrl result(uri);
    return QUrl::fromUserInput(uri).toString();
}


Offloader::~Offloader()
{
}

} /* namespace admin */
