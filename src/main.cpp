#include "applicationui.hpp"
#include "Logger.h"

#include <bb/cascades/Application>

using namespace bb::cascades;
using namespace admin;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);

    registerLogging("ui");
    ApplicationUI appui;

    return Application::exec();
}
