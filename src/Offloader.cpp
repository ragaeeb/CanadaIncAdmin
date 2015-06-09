#include "precompiled.h"

#include "Offloader.h"
#include "QueryId.h"

#define ATTRIBUTE_TYPE_BIO "bio"
#define KEY_ATTRIBUTE_TYPE "type"

namespace admin {

Offloader::Offloader()
{
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
