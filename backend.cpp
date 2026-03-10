#include "backend.h"
#include <QStandardPaths>
#include <QDirIterator>
#include <QFileInfo>
#include <QProcess>
#include <QDesktopServices>
#include <QUrl>
#include <QTimer>

Backend::Backend(QObject *parent) : QObject(parent)
{
    // Defer indexing so it doesn't block startup
    QTimer::singleShot(100, this, &Backend::indexApps);
}

void Backend::indexApps()
{
    m_apps.clear();
    QStringList locations = QStandardPaths::standardLocations(QStandardPaths::ApplicationsLocation);
    locations << QStandardPaths::standardLocations(QStandardPaths::DesktopLocation);
    locations << QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
    
    for (const QString &loc : locations) {
        QDirIterator it(loc, QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            it.next();
            QFileInfo fi(it.filePath());
            AppItem item;
            item.name = fi.completeBaseName();
            item.path = fi.absoluteFilePath();
            m_apps.append(item);
        }
    }
}

QVariantList Backend::search(const QString &query)
{
    QVariantList results;
    if (query.isEmpty()) return results;
    
    QString lowerQuery = query.toLower();
    
    for (const AppItem &item : m_apps) {
        if (item.name.toLower().contains(lowerQuery)) {
            QVariantMap map;
            map["name"] = item.name;
            map["path"] = item.path;
            map["type"] = "App";
            results.append(map);
            if (results.size() >= 10) break; // Limit results
        }
    }
    
    return results;
}

void Backend::launch(const QString &path)
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}
