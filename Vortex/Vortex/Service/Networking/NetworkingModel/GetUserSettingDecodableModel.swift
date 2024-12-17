//
//  GetUserSettingDecodableModel.swift
//  ForaBank
//
//  Created by Mikhail on 22.09.2021.
//

import Foundation

// MARK: - GetUserSettingDecodableModel
struct GetUserSettingDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: UserSettingListDatum?
}

// MARK: GetUserSettingDecodableModel convenience initializers and mutators

extension GetUserSettingDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetUserSettingDecodableModel.self, from: data)
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
        statusCode: Int?? = nil,
        errorMessage: String?? = nil,
        data: UserSettingListDatum?? = nil
    ) -> GetUserSettingDecodableModel {
        return GetUserSettingDecodableModel(
            statusCode: statusCode ?? self.statusCode,
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

// MARK: - UserSettingListDatum
struct UserSettingListDatum: Codable {
    let userSettingList: [UserSetting]?
}


// MARK: Datum convenience initializers and mutators

extension UserSettingListDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserSettingListDatum.self, from: data)
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
        userSettingList: [UserSetting]? = nil
    ) -> UserSettingListDatum {
        return UserSettingListDatum (
            userSettingList: userSettingList ?? self.userSettingList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - UserSetting
struct UserSetting: Codable {
    let sysName: String?
    let name: String?
    let value: String?
   
}

// MARK: ConsentList convenience initializers and mutators

extension UserSetting {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UserSetting.self, from: data)
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
        sysName: String?? = nil,
        name: String?? = nil,
        value: String?? = nil
    ) -> UserSetting {
        return UserSetting(
            sysName: sysName ?? self.sysName,
            name: name ?? self.name,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
