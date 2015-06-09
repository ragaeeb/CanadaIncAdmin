#include "precompiled.h"

#include "applicationui.hpp"
#include "Logger.h"

using namespace bb::cascades;
using namespace admin;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);

    bb::system::InvokeManager i;

    registerLogging( i.startupMode() == ApplicationStartupMode::InvokeCard ? "card" : "ui" );
    ApplicationUI appui(&i);

    return Application::exec();
}
