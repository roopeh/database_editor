#include "DataUpdater.hpp"

#include <QColor>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlField>
#include <QSqlQuery>

DataUpdater::DataUpdater()
{
    m_database = QSqlDatabase::addDatabase("QMYSQL");
}

DataUpdater::~DataUpdater()
{
    m_database.close();

    const auto connName = m_database.connectionName();
    m_database = QSqlDatabase();
    QSqlDatabase::removeDatabase(connName);

    m_countryMap.clear();
    m_cityMap.clear();
}

void DataUpdater::loadSqlTable(uint8_t sortType, bool firstLoad)
{
    m_database.setHostName(dbHostname());
    m_database.setUserName(m_username);
    m_database.setPassword(m_password);
    m_database.setDatabaseName(m_dbName);
    m_database.setPort(m_dbPort.toInt());

    if (firstLoad)
    {
        const auto connectStr = "mysql -h " + dbHostname() + " -u " + dbUsername() + " -p";
        writeQueryLog(connectStr);
    }

    if (tryConnectDatabase())
    {
        if (firstLoad)
        {
            writeDefaultLog("Connected to database");

            // Load all countries and cities to memory
            loadAllCountries();
            loadAllCities();
        }

        QSqlQuery query;
        if (sortType == 0)
            query.prepare("SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id ASC");
        else
            query.prepare("SELECT customer_id, first_name, last_name FROM customer ORDER BY last_name ASC");

        writeQueryLog(getExecutedSqlQuery(query));

        if (!query.exec())
            writeErrorLog(query.lastError().text());
        else
            writeAffectedRows(query.size());

        QVariantMap data;
        while (query.next())
        {
            const auto id = query.value(0).toString();
            const auto firstName = query.value(1).toString();
            const auto lastName = query.value(2).toString();
            if (sortType == 0)
                data.insert(id, QStringLiteral("%1, %2").arg(lastName, firstName));
            else
                data.insert(QStringLiteral("%1, %2").arg(lastName, firstName), id);
        }

        emit loadNewTable(data, sortType);
    }

    m_database.close();
}

void DataUpdater::loadUserInfo(const uint32_t userId)
{
    if (tryConnectDatabase())
    {
        // Create prepared statement
        QSqlQuery query;
        query.prepare("SELECT customer.first_name, customer.last_name, customer.email, address.address, address.postal_code, "
                      "address.phone, address.city_id, country.country_id, customer.address_id FROM customer "
                      "INNER JOIN address ON customer.address_id=address.address_id "
                      "INNER JOIN city ON address.city_id=city.city_id "
                      "INNER JOIN country ON city.country_id=country.country_id "
                      "WHERE customer.customer_id=?");
        query.addBindValue(userId);
        query.exec();

        writeQueryLog(getExecutedSqlQuery(query));

        if (query.next())
        {
            writeAffectedRows(query.size());

            setUserIdField(QString::number(userId));
            setUserFirstname(query.value(0).toString());
            setUserLastname(query.value(1).toString());
            setUserEmail(query.value(2).toString());
            setUserAddress(query.value(3).toString());
            setUserPostalCode(query.value(4).toString());
            setUserPhoneNumber(query.value(5).toString());

            const auto cityId = query.value(6).toUInt();
            const auto countryId = query.value(7).toUInt();
            setUserCountryId(countryId);
            emit setUserCountrySignal(getCountryNameById(countryId));

            setUserCityId(cityId);
            emit setUserCitySignal(getCityNameById(cityId));

            m_userAddressId = query.value(8).toUInt();
        }
        else
        {
            writeErrorLog(query.lastError().text());
        }
    }

    m_database.close();
}

bool DataUpdater::addUser()
{
    if (tryConnectDatabase())
    {
        // Must be done in two queries; one for user table and one for address table
        QSqlQuery query;
        query.prepare("INSERT INTO address "
                      "(address, district, city_id, postal_code, phone, location) VALUES "
                      "(?, ?, ?, ?, ?, POINT(0.0000,90.0000))");
        query.addBindValue(userAddress());
        query.addBindValue("null");
        query.addBindValue(userCityId());
        query.addBindValue(userPostalCode());
        query.addBindValue(userPhoneNumber());

        writeQueryLog(getExecutedSqlQuery(query));

        if (!query.exec())
        {
            writeErrorLog(query.lastError().text());
            m_database.close();
            return false;
        }

        writeAffectedRows(query.numRowsAffected());

        const auto addressId = query.lastInsertId();

        query.clear();
        query.prepare("INSERT INTO customer "
                      "(customer_id, store_id, first_name, last_name, email, address_id) VALUES "
                      "(?, ?, ?, ?, ?, ?)");
        query.addBindValue(userIdField());
        query.addBindValue(1);
        query.addBindValue(userFirstname());
        query.addBindValue(userLastname());
        query.addBindValue(userEmail());
        query.addBindValue(addressId);

        writeQueryLog(getExecutedSqlQuery(query));

        if (!query.exec())
        {
            writeErrorLog(query.lastError().text());
            m_database.close();
            return false;
        }

        writeAffectedRows(query.numRowsAffected());

        m_database.close();
        return true;
    }

    return false;
}

bool DataUpdater::updateUser()
{
    if (tryConnectDatabase())
    {
        QSqlQuery query;
        query.prepare("UPDATE customer "
                      "INNER JOIN address ON customer.address_id=address.address_id "
                      "SET customer.first_name=?, customer.last_name=?, customer.email=?, address.address=?, "
                      "address.postal_code=?, address.phone=?, address.city_id=? WHERE customer.customer_id=?");
        query.addBindValue(userFirstname());
        query.addBindValue(userLastname());
        query.addBindValue(userEmail());
        query.addBindValue(userAddress());
        query.addBindValue(userPostalCode());
        query.addBindValue(userPhoneNumber());
        query.addBindValue(userCityId());
        query.addBindValue(userIdField());

        writeQueryLog(getExecutedSqlQuery(query));

        if (!query.exec())
        {
            writeErrorLog(query.lastError().text());
            m_database.close();
            return false;
        }

        writeAffectedRows(query.numRowsAffected());

        m_database.close();
        return true;
    }

    return false;
}

bool DataUpdater::removeUser()
{
    if (tryConnectDatabase())
    {
        QSqlQuery query;
        query.prepare("DELETE FROM customer WHERE customer_id=?");
        query.addBindValue(userIdField());

        writeQueryLog(getExecutedSqlQuery(query));

        if (!query.exec())
        {
            writeErrorLog(query.lastError().text());
            m_database.close();
            return false;
        }

        writeAffectedRows(query.numRowsAffected());

        m_database.close();
        return true;
    }

    return false;
}

uint8_t DataUpdater::getCountryIdByName(const QString name) const
{
    auto itr = m_countryMap.constBegin();
    while (itr != m_countryMap.constEnd())
    {
        if (itr.value() == name)
            return itr.key();

        ++itr;
    }

    return 0;
}

QString DataUpdater::getCountryNameById(const uint8_t id) const
{
    auto itr = m_countryMap.constBegin();
    while (itr != m_countryMap.constEnd())
    {
        if (itr.key() == id)
            return itr.value();

        ++itr;
    }

    return QString();
}

void DataUpdater::loadCitiesForCountryId(const uint8_t countryId)
{
    QVariantList data;

    auto itr = m_cityMap.constBegin();
    while (itr != m_cityMap.constEnd())
    {
        if (itr.value().second == countryId)
            data.append(itr.value().first);

        ++itr;
    }

    emit loadCitiesToList(data);
}

uint16_t DataUpdater::getCityIdByName(const QString name) const
{
    auto itr = m_cityMap.constBegin();
    while (itr != m_cityMap.constEnd())
    {
        if (itr.value().first == name)
            return itr.key();

        ++itr;
    }

    return 0;
}

QString DataUpdater::getCityNameById(const uint16_t id) const
{
    auto itr = m_cityMap.constBegin();
    while (itr != m_cityMap.constEnd())
    {
        if (itr.key() == id)
            return itr.value().first;

        ++itr;
    }

    return QString();
}

void DataUpdater::writeDefaultLog(const QString message)
{
    const auto str = "<font color=\"#008000\">" + message + "</font>";
    emit appendNewLogMessage(str);
}

void DataUpdater::writeAffectedRows(const int rows)
{
    const auto message = "Affected " + QString::number(rows) + " rows";
    writeDefaultLog(message);
}

void DataUpdater::writeQueryLog(const QString message)
{
    const auto queryStr = "> " + message;
    emit appendNewLogMessage(queryStr);
}

void DataUpdater::writeErrorLog(const QString message)
{
    const auto errorStr = "<font color=\"#FF0000\">" + message + "</font>";
    emit appendNewLogMessage(errorStr);
}

bool DataUpdater::tryConnectDatabase()
{
    if (!m_database.open())
    {
        writeErrorLog(m_database.lastError().text());
        emit connectedToDatabase(false);
        return false;
    }

    emit connectedToDatabase(true);
    return true;
}

void DataUpdater::loadAllCountries()
{
    if (tryConnectDatabase())
    {
        m_countryMap.clear();
        QVariantList data;

        QSqlQuery query("SELECT country_id, country from country ORDER BY country_id ASC");

        writeQueryLog(query.lastQuery());
        if (!query.exec())
        {
            writeErrorLog(query.lastError().text());
            m_database.close();
            return;
        }

        writeAffectedRows(query.size());

        while (query.next())
        {
            const auto countryId = query.value(0).toUInt();
            const auto countryName = query.value(1).toString();

            m_countryMap.insert(countryId, countryName);
            data.append(countryName);
        }

        emit loadCountriesToList(data);
    }
}

void DataUpdater::loadAllCities()
{
    if (tryConnectDatabase())
    {
        m_cityMap.clear();

        QSqlQuery query("SELECT city_id, city, country_id FROM city ORDER BY city_id ASC");

        writeQueryLog(query.lastQuery());
        if (!query.exec())
        {
            writeErrorLog(query.lastError().text());
            m_database.close();
            return;
        }

        writeAffectedRows(query.size());

        while (query.next())
        {
            const auto cityId = query.value(0).toUInt();
            const auto cityName = query.value(1).toString();
            const auto countryId = query.value(2).toUInt();

            m_cityMap.insert(cityId, qMakePair(cityName, countryId));
        }
    }
}

QString DataUpdater::getExecutedSqlQuery(const QSqlQuery& query) const
{
    auto queryStr = query.lastQuery();

    for (int16_t i = 0, j = 0; j < query.boundValues().size(); ++j)
    {
        i = queryStr.indexOf(QLatin1Char('?'), 1);
        if (i <= 0)
            break;

        const QVariant& var = query.boundValue(j);
        QSqlField field(QLatin1String(""), var.metaType());
        if (var.isNull())
            field.clear();
        else
            field.setValue(var);

        auto format = query.driver()->formatValue(field);
        queryStr.replace(i, 1, format);
        i += format.length();
    }

    return queryStr;
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

QString DataUpdater::userFirstname() const
{
    return m_userFirstName;
}

void DataUpdater::setUserFirstname(const QString firstName)
{
    m_userFirstName = firstName;
    emit userFirstnameChanged();
}

QString DataUpdater::userLastname() const
{
    return m_userLastName;
}

void DataUpdater::setUserLastname(const QString lastName)
{
    m_userLastName = lastName;
    emit userLastnameChanged();
}

QString DataUpdater::userEmail() const
{
    return m_userEmail;
}

void DataUpdater::setUserEmail(const QString email)
{
    m_userEmail = email;
    emit userEmailChanged();
}

QString DataUpdater::userIdField() const
{
    return m_userIdField;
}

void DataUpdater::setUserIdField(const QString userId)
{
    m_userIdField = userId;
    emit userIdFieldChanged();
}

QString DataUpdater::userAddress() const
{
    return m_userAddress;
}

void DataUpdater::setUserAddress(const QString address)
{
    m_userAddress = address;
    emit userAddressChanged();
}

QString DataUpdater::userPostalCode() const
{
    return m_userPostalCode;
}

void DataUpdater::setUserPostalCode(const QString postalCode)
{
    m_userPostalCode = postalCode;
    emit userPostalCodeChanged();
}

QString DataUpdater::userPhoneNumber() const
{
    return m_userPhoneNumber;
}

void DataUpdater::setUserPhoneNumber(const QString phoneNumber)
{
    m_userPhoneNumber = phoneNumber;
    emit userPhoneNumberChanged();
}

uint16_t DataUpdater::userCityId() const
{
    return m_userCityId;
}

void DataUpdater::setUserCityId(const uint16_t cityId)
{
    m_userCityId = cityId;
}

uint8_t DataUpdater::userCountryId() const
{
    return m_userCountryId;
}

void DataUpdater::setUserCountryId(const uint8_t countryId)
{
    m_userCountryId = countryId;
}
