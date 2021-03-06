#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QThreadPool>

#include "DataUpdater.hpp"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // Window title
    QCoreApplication::setApplicationName("Database Editor");

    // Initialize multithreading
    QThreadPool::globalInstance()->setMaxThreadCount(QThread::idealThreadCount());

    // Register C++ classes for QML
    qmlRegisterType<DataUpdater>("DataUpdater", 0, 1, "DataUpdater");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
