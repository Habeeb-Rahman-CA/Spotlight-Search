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
    
    QList<AppItem> matches;
    for (const AppItem &item : m_apps) {
        if (item.name.toLower().contains(lowerQuery)) {
            matches.append(item);
        }
    }

    // Sort: prefix matches first, then contains
    std::sort(matches.begin(), matches.end(), [&](const AppItem &a, const AppItem &b) {
        bool aPrefix = a.name.toLower().startsWith(lowerQuery);
        bool bPrefix = b.name.toLower().startsWith(lowerQuery);
        if (aPrefix != bPrefix) return aPrefix;
        return a.name.length() < b.name.length(); // Shorter names first
    });

    for (int i = 0; i < qMin(matches.size(), 10); ++i) {
        QVariantMap map;
        map["name"] = matches[i].name;
        map["path"] = matches[i].path;
        map["type"] = "App";
        results.append(map);
    }
    
    return results;
}

void Backend::launch(const QString &path)
{
    if (path.isEmpty()) return;
    bool success = QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    if (!success) {
        // Fallback: try to start as a process if it's an executable
        QProcess::startDetached(path);
    }
}
