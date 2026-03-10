#pragma once

#include <QObject>
#include <QVariant>
#include <QString>

class Backend : public QObject
{
    Q_OBJECT

public:
    explicit Backend(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList search(const QString &query);
    Q_INVOKABLE void launch(const QString &path);

signals:
    void toggleSearchWindow();
    
public slots:
    void indexApps();

private:
    struct AppItem {
        QString name;
        QString path;
    };
    QList<AppItem> m_apps;
};
