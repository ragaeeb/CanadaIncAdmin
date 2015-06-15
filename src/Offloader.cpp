#include "precompiled.h"

#include "Offloader.h"
#include "QueryId.h"
#include "TextUtils.h"

#define ATTRIBUTE_TYPE_BIO "bio"
#define KEY_ATTRIBUTE_TYPE "type"

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


Offloader::~Offloader()
{
}

} /* namespace quran */
