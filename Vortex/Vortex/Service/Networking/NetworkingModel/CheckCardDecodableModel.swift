//
//  CheckCardDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.07.2021.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let checkCardDecodableModel = try CheckCardDecodableModel(json)

import Foundation

// MARK: - CheckCardDecodableModel
struct CheckCardDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CheckCardDataClass?
}

// MARK: CheckCardDecodableModel convenience initializers and mutators

extension CheckCardDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CheckCardDecodableModel.self, from: data)
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
        data: CheckCardDataClass?? = nil
    ) -> CheckCardDecodableModel {
        return CheckCardDecodableModel(
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

// MARK: - CheckCardDataClass
struct CheckCardDataClass: Codable {
    let check: Bool?
    let payeeCurrency: String?
}

// MARK: DataClass convenience initializers and mutators

extension CheckCardDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CheckCardDataClass.self, from: data)
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
        check: Bool?? = nil,
        payeeCurrency: String?? = nil
    ) -> CheckCardDataClass {
        return CheckCardDataClass(
            check: check ?? self.check,
            payeeCurrency: payeeCurrency ?? self.payeeCurrency
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
