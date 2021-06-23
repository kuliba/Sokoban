//
//  GetLatestPaymentsDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getLatestPaymentsDecodableModel = try GetLatestPaymentsDecodableModel(json)

import Foundation

// MARK: - GetLatestPaymentsDecodableModel
struct GetLatestPaymentsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [String: GetLatestPaymentsDatum]?
}

// MARK: GetLatestPaymentsDecodableModel convenience initializers and mutators

extension GetLatestPaymentsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestPaymentsDecodableModel.self, from: data)
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
        data: [String: GetLatestPaymentsDatum]?? = nil
    ) -> GetLatestPaymentsDecodableModel {
        return GetLatestPaymentsDecodableModel(
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

// MARK: - GetLatestPaymentsDatum
struct GetLatestPaymentsDatum: Codable {
    let bankName, bankID, phoneNumber, amount: String?

    enum CodingKeys: String, CodingKey {
        case bankName
        case bankID = "bankId"
        case phoneNumber, amount
    }
}

// MARK: Datum convenience initializers and mutators

extension GetLatestPaymentsDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestPaymentsDatum.self, from: data)
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
        bankID: String?? = nil,
        phoneNumber: String?? = nil,
        amount: String?? = nil
    ) -> GetLatestPaymentsDatum {
        return GetLatestPaymentsDatum(
            bankName: bankName ?? self.bankName,
            bankID: bankID ?? self.bankID,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            amount: amount ?? self.amount
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
