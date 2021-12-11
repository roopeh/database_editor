#include "DataUpdater.hpp"

#include <QSqlQuery>

#ifdef USE_TABLE_MODEL
#include <QSqlRecord>
#endif

DataUpdater::DataUpdater()
{
    m_database = QSqlDatabase::addDatabase("QMYSQL");
}

DataUpdater::~DataUpdater()
{
    if (m_database.open())
        m_database.close();

    const auto connName = m_database.connectionName();
    m_database = QSqlDatabase();
    QSqlDatabase::removeDatabase(connName);
}

void DataUpdater::loadSqlTable()
{
    m_database.setHostName(m_hostname);
    m_database.setUserName(m_username);
    m_database.setPassword(m_password);
    m_database.setDatabaseName(m_dbName);
    m_database.setPort(m_dbPort.toInt());

    qDebug() << "Host: " << m_hostname << ", user: " << m_username << ", pass: " << m_password << ", name: " << m_dbName
             << ", port: " << m_dbPort.toInt();
    if (m_database.open())
    {
        QSqlQuery query("SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id LIMIT 15");
#ifdef USE_TABLE_MODEL
        auto* model = new QSqlQueryModel();
        model->setQuery(query);

        for (uint8_t i = 0; i < model->query().record().count(); ++i)
        {
            const auto name = model->query().record().fieldName(i);
            qDebug() << name;
            model->setHeaderData(i, Qt::Horizontal, name);
        }

        emit loadNewTable(model);
#else
        QVariantMap data;
        while (query.next())
        {
            const auto id = query.value(0).toString();
            const auto firstName = query.value(1).toString();
            const auto lastName = query.value(2).toString();
            data.insert(id, QStringLiteral("%1 %2").arg(lastName, firstName));
        }

        emit loadNewTable(data);
#endif
    }
    else
    {
        qDebug() << "No connection";
    }

    m_database.close();
}

QString DataUpdater::dbHostname() const
{
    return m_hostname;
}

void DataUpdater::setDbHostname(const QString hostname)
{
    m_hostname = hostname;
    emit dbHostnameChanged();
}

QString DataUpdater::dbUsername() const
{
    return m_username;
}

void DataUpdater::setDbUsername(const QString username)
{
    m_username = username;
    emit dbUsernameChanged();
}

QString DataUpdater::dbPassword() const
{
    return m_password;
}

void DataUpdater::setDbPassword(const QString password)
{
    m_password = password;
    emit dbPasswordChanged();
}

QString DataUpdater::dbDatabase() const
{
    return m_dbName;
}

void DataUpdater::setDbDatabase(const QString database)
{
    m_dbName = database;
    emit dbDatabaseChanged();
}

QString DataUpdater::dbPort() const
{
    return m_dbPort;
}

void DataUpdater::setDbPort(const QString port)
{
    m_dbPort = port;
    emit dbPortChanged();
}
