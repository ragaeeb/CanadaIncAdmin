#include "applicationui.hpp"

#include <bb/cascades/Application>

using namespace bb::cascades;
using namespace admin;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);
    ApplicationUI appui;

    return Application::exec();
}
