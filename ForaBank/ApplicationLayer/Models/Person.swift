// FPerson.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fPerson = try FPerson(json)

import Foundation

// MARK: - FPerson
struct FPerson: Codable {
    let result, errorMessage: String?
    let data: FData?
}

// MARK: FPerson convenience initializers and mutators

extension FPerson {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FPerson.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        result: String?? = nil,
        errorMessage: String?? = nil,
        data: FData?? = nil
    ) -> FPerson {
        return FPerson(
            result: result ?? self.result,
            errorMessage: errorMessage ?? self.errorMessage,
            data: data ?? self.data
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// FData.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fData = try FData(json)

import Foundation

// MARK: - FData
struct FData: Codable {
    let personID, externalID: Int?
    let resident: Bool?
    let residentCountry, gender, citizenship, lastname: String?
    let firstname, patronymic, lastnameGenitive, firstnameGenitive: String?
    let patronymicGenitive, lastnameDative, firstnameDative, patronymicDative: String?
    let lastnameInstrumental, firstnameInstrumental, patronymicInstrumental, lastnameLatin: String?
    let firstnameLatin, birthCountry, birthPlace: String?
    let birthDate: Int?
    let documents: [FDocument]?
    let addresses: [JSONAny]?
    let contacts: [FContact]?
    let users: [FUser]?
    let smsQueues: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case personID = "personId"
        case externalID = "externalId"
        case resident, residentCountry, gender, citizenship, lastname, firstname, patronymic, lastnameGenitive, firstnameGenitive, patronymicGenitive, lastnameDative, firstnameDative, patronymicDative, lastnameInstrumental, firstnameInstrumental, patronymicInstrumental, lastnameLatin, firstnameLatin, birthCountry, birthPlace, birthDate, documents, addresses, contacts, users, smsQueues
    }
}

// MARK: FData convenience initializers and mutators

extension FData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FData.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        personID: Int?? = nil,
        externalID: Int?? = nil,
        resident: Bool?? = nil,
        residentCountry: String?? = nil,
        gender: String?? = nil,
        citizenship: String?? = nil,
        lastname: String?? = nil,
        firstname: String?? = nil,
        patronymic: String?? = nil,
        lastnameGenitive: String?? = nil,
        firstnameGenitive: String?? = nil,
        patronymicGenitive: String?? = nil,
        lastnameDative: String?? = nil,
        firstnameDative: String?? = nil,
        patronymicDative: String?? = nil,
        lastnameInstrumental: String?? = nil,
        firstnameInstrumental: String?? = nil,
        patronymicInstrumental: String?? = nil,
        lastnameLatin: String?? = nil,
        firstnameLatin: String?? = nil,
        birthCountry: String?? = nil,
        birthPlace: String?? = nil,
        birthDate: Int?? = nil,
        documents: [FDocument]?? = nil,
        addresses: [JSONAny]?? = nil,
        contacts: [FContact]?? = nil,
        users: [FUser]?? = nil,
        smsQueues: [JSONAny]?? = nil
    ) -> FData {
        return FData(
            personID: personID ?? self.personID,
            externalID: externalID ?? self.externalID,
            resident: resident ?? self.resident,
            residentCountry: residentCountry ?? self.residentCountry,
            gender: gender ?? self.gender,
            citizenship: citizenship ?? self.citizenship,
            lastname: lastname ?? self.lastname,
            firstname: firstname ?? self.firstname,
            patronymic: patronymic ?? self.patronymic,
            lastnameGenitive: lastnameGenitive ?? self.lastnameGenitive,
            firstnameGenitive: firstnameGenitive ?? self.firstnameGenitive,
            patronymicGenitive: patronymicGenitive ?? self.patronymicGenitive,
            lastnameDative: lastnameDative ?? self.lastnameDative,
            firstnameDative: firstnameDative ?? self.firstnameDative,
            patronymicDative: patronymicDative ?? self.patronymicDative,
            lastnameInstrumental: lastnameInstrumental ?? self.lastnameInstrumental,
            firstnameInstrumental: firstnameInstrumental ?? self.firstnameInstrumental,
            patronymicInstrumental: patronymicInstrumental ?? self.patronymicInstrumental,
            lastnameLatin: lastnameLatin ?? self.lastnameLatin,
            firstnameLatin: firstnameLatin ?? self.firstnameLatin,
            birthCountry: birthCountry ?? self.birthCountry,
            birthPlace: birthPlace ?? self.birthPlace,
            birthDate: birthDate ?? self.birthDate,
            documents: documents ?? self.documents,
            addresses: addresses ?? self.addresses,
            contacts: contacts ?? self.contacts,
            users: users ?? self.users,
            smsQueues: smsQueues ?? self.smsQueues
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// FContact.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fContact = try FContact(json)

import Foundation

// MARK: - FContact
struct FContact: Codable {
    let contactID: Int?
    let actual, invalid: Bool?
    let type, data: String?
    let main: Bool?

    enum CodingKeys: String, CodingKey {
        case contactID = "contactId"
        case actual, invalid, type, data, main
    }
}

// MARK: FContact convenience initializers and mutators

extension FContact {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FContact.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        contactID: Int?? = nil,
        actual: Bool?? = nil,
        invalid: Bool?? = nil,
        type: String?? = nil,
        data: String?? = nil,
        main: Bool?? = nil
    ) -> FContact {
        return FContact(
            contactID: contactID ?? self.contactID,
            actual: actual ?? self.actual,
            invalid: invalid ?? self.invalid,
            type: type ?? self.type,
            data: data ?? self.data,
            main: main ?? self.main
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// FDocument.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fDocument = try FDocument(json)

import Foundation

// MARK: - FDocument
struct FDocument: Codable {
    let documentID: Int?
    let actual, main, invalid: Bool?
    let type, series, number, issuanceUnit: String?
    let issuanceUnitCode: String?
    let issuanceDate: Int?

    enum CodingKeys: String, CodingKey {
        case documentID = "documentId"
        case actual, main, invalid, type, series, number, issuanceUnit, issuanceUnitCode, issuanceDate
    }
}

// MARK: FDocument convenience initializers and mutators

extension FDocument {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FDocument.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        documentID: Int?? = nil,
        actual: Bool?? = nil,
        main: Bool?? = nil,
        invalid: Bool?? = nil,
        type: String?? = nil,
        series: String?? = nil,
        number: String?? = nil,
        issuanceUnit: String?? = nil,
        issuanceUnitCode: String?? = nil,
        issuanceDate: Int?? = nil
    ) -> FDocument {
        return FDocument(
            documentID: documentID ?? self.documentID,
            actual: actual ?? self.actual,
            main: main ?? self.main,
            invalid: invalid ?? self.invalid,
            type: type ?? self.type,
            series: series ?? self.series,
            number: number ?? self.number,
            issuanceUnit: issuanceUnit ?? self.issuanceUnit,
            issuanceUnitCode: issuanceUnitCode ?? self.issuanceUnitCode,
            issuanceDate: issuanceDate ?? self.issuanceDate
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// FUser.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fUser = try FUser(json)

import Foundation

// MARK: - FUser
struct FUser: Codable {
    let userID: Int?
    let login, password: String?
    let blocked, passChangeOnLogin: Bool?
    let lastname, firstname, patronymic: String?
    let userPic: String?
    let createDate, lastVisit: Int?
    let authType: String?
    let lastVisitIP: String?
    let documents, userDevices, settings, roles: [JSONAny]?
    let questions: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case login, password, blocked, passChangeOnLogin, lastname, firstname, patronymic, userPic, createDate, lastVisit, authType, lastVisitIP, documents, userDevices, settings, roles, questions
    }
}

// MARK: FUser convenience initializers and mutators

extension FUser {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FUser.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        userID: Int?? = nil,
        login: String?? = nil,
        password: String?? = nil,
        blocked: Bool?? = nil,
        passChangeOnLogin: Bool?? = nil,
        lastname: String?? = nil,
        firstname: String?? = nil,
        patronymic: String?? = nil,
        userPic: String?? = nil,
        createDate: Int?? = nil,
        lastVisit: Int?? = nil,
        authType: String?? = nil,
        lastVisitIP: String?? = nil,
        documents: [JSONAny]?? = nil,
        userDevices: [JSONAny]?? = nil,
        settings: [JSONAny]?? = nil,
        roles: [JSONAny]?? = nil,
        questions: [JSONAny]?? = nil
    ) -> FUser {
        return FUser(
            userID: userID ?? self.userID,
            login: login ?? self.login,
            password: password ?? self.password,
            blocked: blocked ?? self.blocked,
            passChangeOnLogin: passChangeOnLogin ?? self.passChangeOnLogin,
            lastname: lastname ?? self.lastname,
            firstname: firstname ?? self.firstname,
            patronymic: patronymic ?? self.patronymic,
            userPic: userPic ?? self.userPic,
            createDate: createDate ?? self.createDate,
            lastVisit: lastVisit ?? self.lastVisit,
            authType: authType ?? self.authType,
            lastVisitIP: lastVisitIP ?? self.lastVisitIP,
            documents: documents ?? self.documents,
            userDevices: userDevices ?? self.userDevices,
            settings: settings ?? self.settings,
            roles: roles ?? self.roles,
            questions: questions ?? self.questions
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// JSONSchemaSupport.swift

import Foundation

// MARK: - Helper functions for creating encoders and decoders



class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
class JSONNull: Codable {
    public init() {
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
