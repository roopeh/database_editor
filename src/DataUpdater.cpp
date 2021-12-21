#include "DataUpdater.hpp"

#include <QSqlDriver>
#include <QSqlError>
#include <QSqlField>
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
    m_database.close();

    const auto connName = m_database.connectionName();
    m_database = QSqlDatabase();
    QSqlDatabase::removeDatabase(connName);

    m_countryMap.clear();
    m_cityMap.clear();
}

void DataUpdater::loadSqlTable(uint8_t sortType)
{
    m_database.setHostName(dbHostname());
    m_database.setUserName(m_username);
    m_database.setPassword(m_password);
    m_database.setDatabaseName(m_dbName);
    m_database.setPort(m_dbPort.toInt());

    qDebug() << "Host: " << m_hostname << ", user: " << m_username << ", pass: " << m_password << ", name: " << m_dbName
             << ", port: " << m_dbPort.toInt();
    if (tryConnectDatabase())
    {
        // Load all countries and cities to memory
        loadAllCountries();
        loadAllCities();

        QSqlQuery query;
        if (sortType == 0)
            query.prepare("SELECT customer_id, first_name, last_name FROM customer ORDER BY customer_id LIMIT 15");
        else
            query.prepare("SELECT customer_id, first_name, last_name FROM customer ORDER BY last_name LIMIT 15");

        query.exec();
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
            data.insert(id, QStringLiteral("%1, %2").arg(lastName, firstName));
        }

        emit loadNewTable(data);
#endif
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

        qDebug() << "TesT: " << getExecutedSqlQuery(query);

        if (query.next())
        {
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
            qDebug() << "Error: " << query.lastError();
        }
    }

    m_database.close();
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

        qDebug() << "TesT: " << getExecutedSqlQuery(query);

        bool result = false;
        if (query.exec())
        {
            qDebug() << "success";
            result = true;
        }
        else
        {
            qDebug() << "error: " << query.lastError();
        }

        m_database.close();
        return result;
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

bool DataUpdater::tryConnectDatabase()
{
    if (!m_database.open())
    {
        // todo: send error to query window
        qDebug() << "Error in db connection: " << m_database.lastError();
        emit connectedToDatabase(false);
        return false;
    }

    // todo: send to query window??
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
