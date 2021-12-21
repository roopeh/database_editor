#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QVariant>

// Country id, Country name
typedef QMap<uint8_t, QString> CountryMap;
// City id, City name, Country id
typedef QMap<uint16_t, QPair<QString, uint8_t>> CityMap;

class DataUpdater : public QObject
{
    Q_OBJECT
public:
    DataUpdater();
   ~DataUpdater();

    Q_INVOKABLE void loadSqlTable(uint8_t sortType, bool firstLoad);
    Q_INVOKABLE void loadUserInfo(const uint32_t userId);

    Q_INVOKABLE bool addUser();
    Q_INVOKABLE bool updateUser();
    Q_INVOKABLE bool removeUser();

    Q_INVOKABLE uint8_t getCountryIdByName(const QString name) const;
    Q_INVOKABLE QString getCountryNameById(const uint8_t id) const;

    Q_INVOKABLE void loadCitiesForCountryId(const uint8_t countryId);
    Q_INVOKABLE uint16_t getCityIdByName(const QString name) const;
    Q_INVOKABLE QString getCityNameById(const uint16_t id) const;

    Q_INVOKABLE void writeDefaultLog(const QString message);
    Q_INVOKABLE void writeAffectedRows(const int rows);
    Q_INVOKABLE void writeQueryLog(const QString message);
    Q_INVOKABLE void writeErrorLog(const QString message);

private:
    bool tryConnectDatabase();

    void loadAllCountries();
    void loadAllCities();

    QString getExecutedSqlQuery(const QSqlQuery& query) const;

public:
    // Database fields
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

    // User fields
    Q_PROPERTY (QString userFirstname
                READ userFirstname
                WRITE setUserFirstname
                NOTIFY userFirstnameChanged);
    QString userFirstname() const;
    void setUserFirstname(const QString firstName);

    Q_PROPERTY (QString userLastname
                READ userLastname
                WRITE setUserLastname
                NOTIFY userLastnameChanged);
    QString userLastname() const;
    void setUserLastname(const QString lastName);

    Q_PROPERTY (QString userEmail
                READ userEmail
                WRITE setUserEmail
                NOTIFY userEmailChanged);
    QString userEmail() const;
    void setUserEmail(const QString email);

    Q_PROPERTY (QString userIdField
                READ userIdField
                WRITE setUserIdField
                NOTIFY userIdFieldChanged);
    QString userIdField() const;
    void setUserIdField(const QString userId);

    Q_PROPERTY (QString userAddress
                READ userAddress
                WRITE setUserAddress
                NOTIFY userAddressChanged);
    QString userAddress() const;
    void setUserAddress(const QString address);

    Q_PROPERTY (QString userPostalCode
                READ userPostalCode
                WRITE setUserPostalCode
                NOTIFY userPostalCodeChanged);
    QString userPostalCode() const;
    void setUserPostalCode(const QString postalCode);

    Q_PROPERTY (uint16_t userCityId
                READ userCityId
                WRITE setUserCityId
                NOTIFY userCityIdChanged);
    uint16_t userCityId() const;
    void setUserCityId(const uint16_t cityId);

    Q_PROPERTY (uint8_t userCountryId
                READ userCountryId
                WRITE setUserCountryId
                NOTIFY userCountryIdChanged);
    uint8_t userCountryId() const;
    void setUserCountryId(const uint8_t countryId);

    Q_PROPERTY (QString userPhoneNumber
                READ userPhoneNumber
                WRITE setUserPhoneNumber
                NOTIFY userPhoneNumberChanged);
    QString userPhoneNumber() const;
    void setUserPhoneNumber(const QString phoneNumber);

signals:
    void loadNewTable(QVariantMap data, uint8_t sortType);
    void loadCountriesToList(QVariantList data);
    void loadCitiesToList(QVariantList data);

    void dbHostnameChanged();
    void dbUsernameChanged();
    void dbPasswordChanged();
    void dbDatabaseChanged();
    void dbPortChanged();
    void connectedToDatabase(bool connected);

    void userFirstnameChanged();
    void userLastnameChanged();
    void userEmailChanged();
    void userIdFieldChanged();
    void userAddressChanged();
    void userPostalCodeChanged();
    void userCityIdChanged();
    void userCountryIdChanged();
    void userPhoneNumberChanged();
    void setUserCountrySignal(const QString countryName);
    void setUserCitySignal(const QString cityName);

    void appendNewLogMessage(QString message);

private:
    QSqlDatabase m_database = QSqlDatabase();
    QString m_hostname = QString();
    QString m_username = QString();
    QString m_password = QString();
    QString m_dbName = QString();
    QString m_dbPort = QString();

    QString m_userFirstName = QString();
    QString m_userLastName = QString();
    QString m_userEmail = QString();
    QString m_userIdField = QString();
    QString m_userAddress = QString();
    QString m_userPostalCode = QString();
    QString m_userPhoneNumber = QString();
    uint16_t m_userCityId = 0;
    uint8_t m_userCountryId = 0;
    uint16_t m_userAddressId = 0;

    CountryMap m_countryMap;
    CityMap m_cityMap;
};
