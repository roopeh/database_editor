#pragma once

//#define USE_TABLE_MODEL 1

#include <QObject>
#include <QSqlDatabase>

#ifdef USE_TABLE_MODEL
#include <QSqlQueryModel>
#else
#include <QVariant>
#endif

class DataUpdater : public QObject {
    Q_OBJECT
public:
    DataUpdater();
   ~DataUpdater();

    Q_INVOKABLE void loadSqlTable();

signals:

#ifdef USE_TABLE_MODEL
    void loadNewTable(QSqlQueryModel* model);
#else
    void loadNewTable(QVariantMap data);
#endif

private:
    QSqlDatabase m_database;
};
