//
//  CheckClientDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let checkClientDecodebleModel = try CheckClientDecodebleModel(json)

import Foundation

// MARK: - CheckClientDecodebleModel
struct CheckClientDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CheckDataClass?
}

// MARK: CheckClientDecodebleModel convenience initializers and mutators

extension CheckClientDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CheckClientDecodebleModel.self, from: data)
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
        data: CheckDataClass?? = nil
    ) -> CheckClientDecodebleModel {
        return CheckClientDecodebleModel(
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

// MARK: - CheckDataClass
struct CheckDataClass: Codable {
    let phone: String?
}

// MARK: DataClass convenience initializers and mutators

extension CheckDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CheckDataClass.self, from: data)
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
    ) -> CheckDataClass {
        return CheckDataClass(
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
