#include "DataUpdater.hpp"

#include <QSqlQuery>

#ifdef USE_TABLE_MODEL
#include <QSqlRecord>
#endif

namespace TempConnection
{
    const static QString HOST = "";
    const static QString USER = "";
    const static QString PASS = "";
    const static QString DB = "sakila";
}

DataUpdater::DataUpdater()
{
    m_database = QSqlDatabase::addDatabase("QMYSQL");

    // Set temp connection
    m_database.setHostName(TempConnection::HOST);
    m_database.setUserName(TempConnection::USER);
    m_database.setPassword(TempConnection::PASS);
    m_database.setDatabaseName(TempConnection::DB);
}

DataUpdater::~DataUpdater()
{
    if (m_database.open())
        m_database.close();

    m_database.removeDatabase("QMYSQL");
}

void DataUpdater::loadSqlTable()
{
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
