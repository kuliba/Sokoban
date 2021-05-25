import Foundation

struct GetUserSettings : Codable {
    let data : [DatumSettings]?
    let errorMessage : String?
    let result : String?

    enum CodingKeys: String, CodingKey {

        case data = "data"
        case errorMessage = "errorMessage"
        case result = "result"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([DatumSettings].self, forKey: .data)
        errorMessage = try values.decodeIfPresent(String.self, forKey: .errorMessage)
        result = try values.decodeIfPresent(String.self, forKey: .result)
    }

}
struct Addresses : Codable {
    let actual : Bool?
    let addressId : Int?
    let city : String?
    let cityType : String?
    let country : String?
    let district : String?
    let districtType : String?
    let flat : String?
    let house : String?
    let housing : String?
    let invalid : Bool?
    let locality : String?
    let localityType : String?
    let main : Bool?
    let postalCode : String?
    let region : String?
    let regionType : String?
    let registrationDate : String?
    let street : String?
    let streetType : String?
    let structure : String?
    let type : String?

    enum CodingKeys: String, CodingKey {

        case actual = "actual"
        case addressId = "addressId"
        case city = "city"
        case cityType = "cityType"
        case country = "country"
        case district = "district"
        case districtType = "districtType"
        case flat = "flat"
        case house = "house"
        case housing = "housing"
        case invalid = "invalid"
        case locality = "locality"
        case localityType = "localityType"
        case main = "main"
        case postalCode = "postalCode"
        case region = "region"
        case regionType = "regionType"
        case registrationDate = "registrationDate"
        case street = "street"
        case streetType = "streetType"
        case structure = "structure"
        case type = "type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        actual = try values.decodeIfPresent(Bool.self, forKey: .actual)
        addressId = try values.decodeIfPresent(Int.self, forKey: .addressId)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        cityType = try values.decodeIfPresent(String.self, forKey: .cityType)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        district = try values.decodeIfPresent(String.self, forKey: .district)
        districtType = try values.decodeIfPresent(String.self, forKey: .districtType)
        flat = try values.decodeIfPresent(String.self, forKey: .flat)
        house = try values.decodeIfPresent(String.self, forKey: .house)
        housing = try values.decodeIfPresent(String.self, forKey: .housing)
        invalid = try values.decodeIfPresent(Bool.self, forKey: .invalid)
        locality = try values.decodeIfPresent(String.self, forKey: .locality)
        localityType = try values.decodeIfPresent(String.self, forKey: .localityType)
        main = try values.decodeIfPresent(Bool.self, forKey: .main)
        postalCode = try values.decodeIfPresent(String.self, forKey: .postalCode)
        region = try values.decodeIfPresent(String.self, forKey: .region)
        regionType = try values.decodeIfPresent(String.self, forKey: .regionType)
        registrationDate = try values.decodeIfPresent(String.self, forKey: .registrationDate)
        street = try values.decodeIfPresent(String.self, forKey: .street)
        streetType = try values.decodeIfPresent(String.self, forKey: .streetType)
        structure = try values.decodeIfPresent(String.self, forKey: .structure)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

}

struct DatumSettings : Codable {
    let user : User?
    let userSetting : UserSetting?
    let user_id : Int?
    let user_setting_id : Int?
    let value : String?

    enum CodingKeys: String, CodingKey {

        case user = "user"
        case userSetting = "userSetting"
        case user_id = "user_id"
        case user_setting_id = "user_setting_id"
        case value = "value"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        user = try values.decodeIfPresent(User.self, forKey: .user)
        userSetting = try values.decodeIfPresent(UserSetting.self, forKey: .userSetting)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        user_setting_id = try values.decodeIfPresent(Int.self, forKey: .user_setting_id)
        value = try values.decodeIfPresent(String.self, forKey: .value)
    }

}
struct Contacts : Codable {
    let actual : Bool?
    let contactId : Int?
    let data : String?
    let invalid : Bool?
    let main : Bool?
    let type : String?

    enum CodingKeys: String, CodingKey {

        case actual = "actual"
        case contactId = "contactId"
        case data = "data"
        case invalid = "invalid"
        case main = "main"
        case type = "type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        actual = try values.decodeIfPresent(Bool.self, forKey: .actual)
        contactId = try values.decodeIfPresent(Int.self, forKey: .contactId)
        data = try values.decodeIfPresent(String.self, forKey: .data)
        invalid = try values.decodeIfPresent(Bool.self, forKey: .invalid)
        main = try values.decodeIfPresent(Bool.self, forKey: .main)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

}


struct Documents : Codable {
    let actual : Bool?
    let documentId : Int?
    let invalid : Bool?
    let issuanceDate : String?
    let issuanceUnit : String?
    let issuanceUnitCode : String?
    let main : Bool?
    let number : String?
    let series : String?
    let type : String?

    enum CodingKeys: String, CodingKey {

        case actual = "actual"
        case documentId = "documentId"
        case invalid = "invalid"
        case issuanceDate = "issuanceDate"
        case issuanceUnit = "issuanceUnit"
        case issuanceUnitCode = "issuanceUnitCode"
        case main = "main"
        case number = "number"
        case series = "series"
        case type = "type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        actual = try values.decodeIfPresent(Bool.self, forKey: .actual)
        documentId = try values.decodeIfPresent(Int.self, forKey: .documentId)
        invalid = try values.decodeIfPresent(Bool.self, forKey: .invalid)
        issuanceDate = try values.decodeIfPresent(String.self, forKey: .issuanceDate)
        issuanceUnit = try values.decodeIfPresent(String.self, forKey: .issuanceUnit)
        issuanceUnitCode = try values.decodeIfPresent(String.self, forKey: .issuanceUnitCode)
        main = try values.decodeIfPresent(Bool.self, forKey: .main)
        number = try values.decodeIfPresent(String.self, forKey: .number)
        series = try values.decodeIfPresent(String.self, forKey: .series)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }

}
struct OfferSettings : Codable {
    let date : String?
    let offerId : Int?
    let version : String?

    enum CodingKeys: String, CodingKey {

        case date = "date"
        case offerId = "offerId"
        case version = "version"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        offerId = try values.decodeIfPresent(Int.self, forKey: .offerId)
        version = try values.decodeIfPresent(String.self, forKey: .version)
    }

}
struct Person : Codable {
    let addresses : [Addresses]?
    let birthCountry : String?
    let birthDate : String?
    let birthPlace : String?
    let citizenship : String?
    let contacts : [Contacts]?
    let documents : [Documents]?
    let externalId : Int?
    let firstname : String?
    let firstnameDative : String?
    let firstnameGenitive : String?
    let firstnameInstrumental : String?
    let firstnameLatin : String?
    let gender : String?
    let lastname : String?
    let lastnameDative : String?
    let lastnameGenitive : String?
    let lastnameInstrumental : String?
    let lastnameLatin : String?
    let patronymic : String?
    let patronymicDative : String?
    let patronymicGenitive : String?
    let patronymicInstrumental : String?
    let personId : Int?
    let resident : Bool?
    let residentCountry : String?
    let smsQueues : [SmsQueues]?
    let users : [String]?

    enum CodingKeys: String, CodingKey {

        case addresses = "addresses"
        case birthCountry = "birthCountry"
        case birthDate = "birthDate"
        case birthPlace = "birthPlace"
        case citizenship = "citizenship"
        case contacts = "contacts"
        case documents = "documents"
        case externalId = "externalId"
        case firstname = "firstname"
        case firstnameDative = "firstnameDative"
        case firstnameGenitive = "firstnameGenitive"
        case firstnameInstrumental = "firstnameInstrumental"
        case firstnameLatin = "firstnameLatin"
        case gender = "gender"
        case lastname = "lastname"
        case lastnameDative = "lastnameDative"
        case lastnameGenitive = "lastnameGenitive"
        case lastnameInstrumental = "lastnameInstrumental"
        case lastnameLatin = "lastnameLatin"
        case patronymic = "patronymic"
        case patronymicDative = "patronymicDative"
        case patronymicGenitive = "patronymicGenitive"
        case patronymicInstrumental = "patronymicInstrumental"
        case personId = "personId"
        case resident = "resident"
        case residentCountry = "residentCountry"
        case smsQueues = "smsQueues"
        case users = "users"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        addresses = try values.decodeIfPresent([Addresses].self, forKey: .addresses)
        birthCountry = try values.decodeIfPresent(String.self, forKey: .birthCountry)
        birthDate = try values.decodeIfPresent(String.self, forKey: .birthDate)
        birthPlace = try values.decodeIfPresent(String.self, forKey: .birthPlace)
        citizenship = try values.decodeIfPresent(String.self, forKey: .citizenship)
        contacts = try values.decodeIfPresent([Contacts].self, forKey: .contacts)
        documents = try values.decodeIfPresent([Documents].self, forKey: .documents)
        externalId = try values.decodeIfPresent(Int.self, forKey: .externalId)
        firstname = try values.decodeIfPresent(String.self, forKey: .firstname)
        firstnameDative = try values.decodeIfPresent(String.self, forKey: .firstnameDative)
        firstnameGenitive = try values.decodeIfPresent(String.self, forKey: .firstnameGenitive)
        firstnameInstrumental = try values.decodeIfPresent(String.self, forKey: .firstnameInstrumental)
        firstnameLatin = try values.decodeIfPresent(String.self, forKey: .firstnameLatin)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        lastname = try values.decodeIfPresent(String.self, forKey: .lastname)
        lastnameDative = try values.decodeIfPresent(String.self, forKey: .lastnameDative)
        lastnameGenitive = try values.decodeIfPresent(String.self, forKey: .lastnameGenitive)
        lastnameInstrumental = try values.decodeIfPresent(String.self, forKey: .lastnameInstrumental)
        lastnameLatin = try values.decodeIfPresent(String.self, forKey: .lastnameLatin)
        patronymic = try values.decodeIfPresent(String.self, forKey: .patronymic)
        patronymicDative = try values.decodeIfPresent(String.self, forKey: .patronymicDative)
        patronymicGenitive = try values.decodeIfPresent(String.self, forKey: .patronymicGenitive)
        patronymicInstrumental = try values.decodeIfPresent(String.self, forKey: .patronymicInstrumental)
        personId = try values.decodeIfPresent(Int.self, forKey: .personId)
        resident = try values.decodeIfPresent(Bool.self, forKey: .resident)
        residentCountry = try values.decodeIfPresent(String.self, forKey: .residentCountry)
        smsQueues = try values.decodeIfPresent([SmsQueues].self, forKey: .smsQueues)
        users = try values.decodeIfPresent([String].self, forKey: .users)
    }

}
struct Questions : Codable {
    let questionData : String?
    let questionId : Int?
    let users : [String]?

    enum CodingKeys: String, CodingKey {

        case questionData = "questionData"
        case questionId = "questionId"
        case users = "users"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        questionData = try values.decodeIfPresent(String.self, forKey: .questionData)
        questionId = try values.decodeIfPresent(Int.self, forKey: .questionId)
        users = try values.decodeIfPresent([String].self, forKey: .users)
    }

}
struct Roles : Codable {
    let roleId : Int?
    let roleName : String?
    let roleSysName : String?
    let users : [String]?

    enum CodingKeys: String, CodingKey {

        case roleId = "roleId"
        case roleName = "roleName"
        case roleSysName = "roleSysName"
        case users = "users"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        roleId = try values.decodeIfPresent(Int.self, forKey: .roleId)
        roleName = try values.decodeIfPresent(String.self, forKey: .roleName)
        roleSysName = try values.decodeIfPresent(String.self, forKey: .roleSysName)
        users = try values.decodeIfPresent([String].self, forKey: .users)
    }

}
struct SmsQueues : Codable {
    let externalId : Int?
    let sent : Bool?
    let smsDate : String?
    let smsQueueId : Int?
    let smsText : String?

    enum CodingKeys: String, CodingKey {

        case externalId = "externalId"
        case sent = "sent"
        case smsDate = "smsDate"
        case smsQueueId = "smsQueueId"
        case smsText = "smsText"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        externalId = try values.decodeIfPresent(Int.self, forKey: .externalId)
        sent = try values.decodeIfPresent(Bool.self, forKey: .sent)
        smsDate = try values.decodeIfPresent(String.self, forKey: .smsDate)
        smsQueueId = try values.decodeIfPresent(Int.self, forKey: .smsQueueId)
        smsText = try values.decodeIfPresent(String.self, forKey: .smsText)
    }

}
struct User : Codable {
    let authType : String?
    let blocked : Bool?
    let createDate : String?
    let documents : [Documents]?
    let firstname : String?
    let lastVisit : String?
    let lastVisitIP : String?
    let lastname : String?
    let login : String?
    let offer : OfferSettings?
    let passChangeOnLogin : Bool?
    let password : String?
    let patronymic : String?
    let person : Person?
    let questions : [Questions]?
    let roles : [Roles]?
    let settings : [String]?
    let userDevices : [UserDevices]?
    let userId : Int?
    let userPic : String?

    enum CodingKeys: String, CodingKey {

        case authType = "authType"
        case blocked = "blocked"
        case createDate = "createDate"
        case documents = "documents"
        case firstname = "firstname"
        case lastVisit = "lastVisit"
        case lastVisitIP = "lastVisitIP"
        case lastname = "lastname"
        case login = "login"
        case offer = "offer"
        case passChangeOnLogin = "passChangeOnLogin"
        case password = "password"
        case patronymic = "patronymic"
        case person = "person"
        case questions = "questions"
        case roles = "roles"
        case settings = "settings"
        case userDevices = "userDevices"
        case userId = "userId"
        case userPic = "userPic"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authType = try values.decodeIfPresent(String.self, forKey: .authType)
        blocked = try values.decodeIfPresent(Bool.self, forKey: .blocked)
        createDate = try values.decodeIfPresent(String.self, forKey: .createDate)
        documents = try values.decodeIfPresent([Documents].self, forKey: .documents)
        firstname = try values.decodeIfPresent(String.self, forKey: .firstname)
        lastVisit = try values.decodeIfPresent(String.self, forKey: .lastVisit)
        lastVisitIP = try values.decodeIfPresent(String.self, forKey: .lastVisitIP)
        lastname = try values.decodeIfPresent(String.self, forKey: .lastname)
        login = try values.decodeIfPresent(String.self, forKey: .login)
        offer = try values.decodeIfPresent(OfferSettings.self, forKey: .offer)
        passChangeOnLogin = try values.decodeIfPresent(Bool.self, forKey: .passChangeOnLogin)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        patronymic = try values.decodeIfPresent(String.self, forKey: .patronymic)
        person = try values.decodeIfPresent(Person.self, forKey: .person)
        questions = try values.decodeIfPresent([Questions].self, forKey: .questions)
        roles = try values.decodeIfPresent([Roles].self, forKey: .roles)
        settings = try values.decodeIfPresent([String].self, forKey: .settings)
        userDevices = try values.decodeIfPresent([UserDevices].self, forKey: .userDevices)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
        userPic = try values.decodeIfPresent(String.self, forKey: .userPic)
    }

}
struct UserDevices : Codable {
    let deviceId : String?
    let deviceInfo : String?
    let lastVisitDate : String?
    let userDeviceId : Int?

    enum CodingKeys: String, CodingKey {

        case deviceId = "deviceId"
        case deviceInfo = "deviceInfo"
        case lastVisitDate = "lastVisitDate"
        case userDeviceId = "userDeviceId"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        deviceId = try values.decodeIfPresent(String.self, forKey: .deviceId)
        deviceInfo = try values.decodeIfPresent(String.self, forKey: .deviceInfo)
        lastVisitDate = try values.decodeIfPresent(String.self, forKey: .lastVisitDate)
        userDeviceId = try values.decodeIfPresent(Int.self, forKey: .userDeviceId)
    }

}
struct UserSetting : Codable {
    let name : String?
    let sysName : String?
    let userSettingId : Int?
    let users : [String]?

    enum CodingKeys: String, CodingKey {

        case name = "name"
        case sysName = "sysName"
        case userSettingId = "userSettingId"
        case users = "users"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        sysName = try values.decodeIfPresent(String.self, forKey: .sysName)
        userSettingId = try values.decodeIfPresent(Int.self, forKey: .userSettingId)
        users = try values.decodeIfPresent([String].self, forKey: .users)
    }

}
