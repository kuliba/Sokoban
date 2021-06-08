//
//  SetDeviceSettingDecodbleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.06.2021.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let setDeviceSetttingDecodbleModel = try SetDeviceSetttingDecodbleModel(json)

// MARK: - SetDeviceSettingDecodbleModel
struct SetDeviceSettingDecodbleModel: Codable, NetworkModelProtocol {
    let cryptoVersion, pushDeviceID, pushFcmToken, serverDeviceGUID: String?
    let settings: [Setting]?

    enum CodingKeys: String, CodingKey {
        case cryptoVersion
        case pushDeviceID = "pushDeviceId"
        case pushFcmToken, serverDeviceGUID, settings
    }
}

// MARK: SetDeviceSetttingDecodbleModel convenience initializers and mutators

extension SetDeviceSettingDecodbleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SetDeviceSettingDecodbleModel.self, from: data)
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
        cryptoVersion: String?? = nil,
        pushDeviceID: String?? = nil,
        pushFcmToken: String?? = nil,
        serverDeviceGUID: String?? = nil,
        settings: [Setting]?? = nil
    ) -> SetDeviceSettingDecodbleModel {
        return SetDeviceSettingDecodbleModel(
            cryptoVersion: cryptoVersion ?? self.cryptoVersion,
            pushDeviceID: pushDeviceID ?? self.pushDeviceID,
            pushFcmToken: pushFcmToken ?? self.pushFcmToken,
            serverDeviceGUID: serverDeviceGUID ?? self.serverDeviceGUID,
            settings: settings ?? self.settings
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Setting
struct Setting: Codable {
    let isActive: Bool?
    let type, value: String?
}

extension Setting {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Setting.self, from: data)
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
        isActive: Bool?? = nil,
        type: String?? = nil,
        value: String?? = nil
    ) -> Setting {
        return Setting(
            isActive: isActive ?? self.isActive,
            type: type ?? self.type,
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

