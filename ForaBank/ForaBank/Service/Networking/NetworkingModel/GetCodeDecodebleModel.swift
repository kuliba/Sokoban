//
//  GetCodeDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getCodeDecodebleModel = try GetCodeDecodebleModel(json)

import Foundation

// MARK: - GetCodeDecodebleModel
struct GetCodeDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: JSONNull?
    let data: GetCodeDataClass?
}

// MARK: GetCodeDecodebleModel convenience initializers and mutators

extension GetCodeDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCodeDecodebleModel.self, from: data)
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
        errorMessage: JSONNull?? = nil,
        data: GetCodeDataClass?? = nil
    ) -> GetCodeDecodebleModel {
        return GetCodeDecodebleModel(
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

// MARK: - DataClass
struct GetCodeDataClass: Codable {
    let resendOTPCount: Int?
}

// MARK: DataClass convenience initializers and mutators

extension GetCodeDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCodeDataClass.self, from: data)
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
        resendOTPCount: Int?? = nil
    ) -> GetCodeDataClass {
        return GetCodeDataClass(
            resendOTPCount: resendOTPCount ?? self.resendOTPCount
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
