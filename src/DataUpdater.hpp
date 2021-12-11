#pragma once

//#define USE_TABLE_MODEL 1

#include <QObject>
#include <QSqlDatabase>

#ifdef USE_TABLE_MODEL
#include <QSqlQueryModel>
#else
#include <QVariant>
#endif

class DataUpdater : public QObject
{
    Q_OBJECT
public:
    DataUpdater();
   ~DataUpdater();

    Q_INVOKABLE void loadSqlTable();

    Q_PROPERTY (QString dbHostname
                READ dbHostname
                WRITE setDbHostname
                NOTIFY dbHostnameChanged);
    QString dbHostname() const;
    void setDbHostname(const QString hostname);

    Q_PROPERTY (QString dbUsername
                READ dbUsername
                WRITE setDbUsername
                NOTIFY dbUsernameChanged);
    QString dbUsername() const;
    void setDbUsername(const QString username);

    Q_PROPERTY (QString dbPassword
                READ dbPassword
                WRITE setDbPassword
                NOTIFY dbPasswordChanged);
    QString dbPassword() const;
    void setDbPassword(const QString password);

    Q_PROPERTY (QString dbDatabase
                READ dbDatabase
                WRITE setDbDatabase
                NOTIFY dbDatabaseChanged);
    QString dbDatabase() const;
    void setDbDatabase(const QString database);

    Q_PROPERTY (QString dbPort
                READ dbPort
                WRITE setDbPort
                NOTIFY dbPortChanged);
    QString dbPort() const;
    void setDbPort(const QString port);

signals:
#ifdef USE_TABLE_MODEL
    void loadNewTable(QSqlQueryModel* model);
#else
    void loadNewTable(QVariantMap data);
#endif

    void dbHostnameChanged();
    void dbUsernameChanged();
    void dbPasswordChanged();
    void dbDatabaseChanged();
    void dbPortChanged();

private:
    QSqlDatabase m_database = QSqlDatabase();
    QString m_hostname = QString();
    QString m_username = QString();
    QString m_password = QString();
    QString m_dbName = QString();
    QString m_dbPort = QString();
};
