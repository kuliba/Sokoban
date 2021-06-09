//
//  SetDeviceSettingDecodbleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let setDeviceSettingDecodbleModel = try SetDeviceSettingDecodbleModel(json)

import Foundation

// MARK: - SetDeviceSettingDecodbleModel
struct SetDeviceSettingDecodbleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: String?
}

// MARK: SetDeviceSettingDecodbleModel convenience initializers and mutators

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
        statusCode: Int?? = nil,
        errorMessage: String?? = nil,
        data: String?? = nil
    ) -> SetDeviceSettingDecodbleModel {
        return SetDeviceSettingDecodbleModel(
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
