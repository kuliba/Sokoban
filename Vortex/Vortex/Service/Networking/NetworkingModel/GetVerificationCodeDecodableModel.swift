//
//  GetVerificationCodeDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getVerificationCodeDecodableModel = try GetVerificationCodeDecodableModel(json)

import Foundation

// MARK: - GetVerificationCodeDecodableModel
struct GetVerificationCodeDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetVerificationDataClass?
}

// MARK: GetVerificationCodeDecodableModel convenience initializers and mutators

extension GetVerificationCodeDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetVerificationCodeDecodableModel.self, from: data)
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
        data: GetVerificationDataClass?? = nil
    ) -> GetVerificationCodeDecodableModel {
        return GetVerificationCodeDecodableModel(
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

// MARK: - GetVerificationDataClass
struct GetVerificationDataClass: Codable {
    let resendOTPCount: Int?
}

// MARK: GetVerificationDataClass convenience initializers and mutators

extension GetVerificationDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetVerificationDataClass.self, from: data)
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
    ) -> GetVerificationDataClass {
        return GetVerificationDataClass(
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
