//
//  GetPrintFormDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getLatestPhonePaymentsDecodableModel = try GetLatestPhonePaymentsDecodableModel(json)

import Foundation

// MARK: - GetLatestPhonePaymentsDecodableModel
struct GetLatestPhonePaymentsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetLatestPhone]?
}

// MARK: GetLatestPhonePaymentsDecodableModel convenience initializers and mutators

extension GetLatestPhonePaymentsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestPhonePaymentsDecodableModel.self, from: data)
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
        data: [GetLatestPhone]?? = nil
    ) -> GetLatestPhonePaymentsDecodableModel {
        return GetLatestPhonePaymentsDecodableModel(
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

// Datum.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let datum = try Datum(json)


// MARK: - GetLatestPhone
struct GetLatestPhone: Codable {
    let bankName, bankID: String?
    let payment: Bool?

    enum CodingKeys: String, CodingKey {
        case bankName
        case bankID = "bankId"
        case payment
    }
}

// MARK: Datum convenience initializers and mutators

extension GetLatestPhone {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestPhone.self, from: data)
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
        bankName: String?? = nil,
        bankID: String?? = nil
    ) -> GetLatestPhone {
        return GetLatestPhone(
            bankName: bankName ?? self.bankName,
            bankID: bankID ?? self.bankID,
            payment: payment ?? false
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
