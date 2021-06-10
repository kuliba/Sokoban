//
//  InstallPushDeviceDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let installPushDeviceDecodebleModel = try InstallPushDeviceDecodebleModel(json)

import Foundation

// MARK: - InstallPushDeviceDecodebleModel
struct InstallPushDeviceDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: PushDeviceDataClass?
}

// MARK: InstallPushDeviceDecodebleModel convenience initializers and mutators

extension InstallPushDeviceDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(InstallPushDeviceDecodebleModel.self, from: data)
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
        data: PushDeviceDataClass?? = nil
    ) -> InstallPushDeviceDecodebleModel {
        return InstallPushDeviceDecodebleModel(
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

// DataClass.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let dataClass = try DataClass(json)

import Foundation

// MARK: - PushDeviceDataClass
struct PushDeviceDataClass: Codable {
    let phone: String?
}

// MARK: DataClass convenience initializers and mutators

extension PushDeviceDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PushDeviceDataClass.self, from: data)
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
        phone: String?? = nil
    ) -> PushDeviceDataClass {
        return PushDeviceDataClass(
            phone: phone ?? self.phone
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
