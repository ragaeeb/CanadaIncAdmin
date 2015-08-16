#include "TokenHelper.h"

namespace admin {

QVariantMap TokenHelper::getTokensForIndividual(QString const& prefix, QString const& name, QString const& kunya, QString const& displayName, bool hidden, int birth, int death, bool female, QString const& location, QString const& currentLocation, int level, QString const& description)
{
    QVariantMap keyValues;
    keyValues["birth"] = birth;
    keyValues["current_location"] = currentLocation.toLongLong();
    keyValues["death"] = death;
    keyValues["notes"] = description;
    keyValues["displayName"] = displayName;
    keyValues["female"] = ( female ? 1 : QVariant() );
    keyValues["hidden"] = ( hidden ? 1 : QVariant() );
    keyValues["is_companion"] = level;
    keyValues["kunya"] = kunya;
    keyValues["location"] = location.toLongLong();
    keyValues["name"] = name;
    keyValues["prefix"] = prefix;

    return keyValues;
}

} /* namespace admin */
