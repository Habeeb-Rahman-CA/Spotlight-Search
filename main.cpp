#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QFileIconProvider>
#include <QIcon>
#include <QFileInfo>
#include <QPixmap>
#include <QSystemTrayIcon>
#include <QMenu>
#include <QAction>
#include "backend.h"

class FileIconProvider : public QQuickImageProvider
{
public:
    FileIconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}

    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override {
        QFileIconProvider provider;
        QIcon icon = provider.icon(QFileInfo(id));
        QSize actualSize = requestedSize.isValid() ? requestedSize : QSize(36, 36);
        if (size) *size = actualSize;
        return icon.pixmap(actualSize);
    }
};

#ifdef Q_OS_WIN
#include <windows.h>
#include <QAbstractNativeEventFilter>

class HotkeyFilter : public QAbstractNativeEventFilter
{
public:
    HotkeyFilter(Backend *backend) : m_backend(backend) {}
    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override {
        Q_UNUSED(eventType)
        Q_UNUSED(result)
        MSG *msg = static_cast<MSG*>(message);
        if (msg->message == WM_HOTKEY) {
            if (msg->wParam == 1) { // 1 is the hotkey id
                emit m_backend->toggleSearchWindow();
                return true;
            }
        }
        return false;
    }
private:
    Backend *m_backend;
};
#endif

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("Trinode");
    app.setOrganizationName("Trinode");
    app.setWindowIcon(QIcon(":/qt/qml/Trinode/assets/logo.png"));
    app.setQuitOnLastWindowClosed(false);

    // System Tray Icon
    QSystemTrayIcon trayIcon(QIcon(":/qt/qml/Trinode/assets/logo.png"), &app);
    QMenu *trayMenu = new QMenu();
    QAction *quitAction = trayMenu->addAction("Quit Trinode");
    QObject::connect(quitAction, &QAction::triggered, &app, &QCoreApplication::quit);
    trayIcon.setContextMenu(trayMenu);
    trayIcon.setToolTip("Trinode - Search Everything");
    trayIcon.show();

    Backend backend;

#ifdef Q_OS_WIN
    // Register Ctrl+Space hotkey
    RegisterHotKey(NULL, 1, MOD_CONTROL | MOD_SHIFT, VK_SPACE);
    app.installNativeEventFilter(new HotkeyFilter(&backend));
#endif

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Backend", &backend);
    engine.addImageProvider("fileicon", new FileIconProvider);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("Trinode", "Main");

    int ret = app.exec();

#ifdef Q_OS_WIN
    UnregisterHotKey(NULL, 1);
#endif

    return ret;
}
