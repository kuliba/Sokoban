//
//  PrepareExternalDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let prepareExternalDecodableModel = try PrepareExternalDecodableModel(json)

import Foundation

// MARK: - PrepareExternalDecodableModel
struct PrepareExternalDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: PrepareExternalDataClass?
}

// MARK: PrepareExternalDecodableModel convenience initializers and mutators

extension PrepareExternalDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrepareExternalDecodableModel.self, from: data)
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
        data: PrepareExternalDataClass?? = nil
    ) -> PrepareExternalDecodableModel {
        return PrepareExternalDecodableModel(
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

// MARK: - PrepareExternalDataClass
struct PrepareExternalDataClass: Codable {
    let payerCardNumber, payerAccountNumber, payeeCardNumber, payeeAccountNumber: String?
    let payeePhone, payeeName: String?
    let amount: Int?
    let currencyAmount: String?
    let commission: [String]?
}

// MARK: PrepareExternalDataClass convenience initializers and mutators

extension PrepareExternalDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrepareExternalDataClass.self, from: data)
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
        payerCardNumber: String?? = nil,
        payerAccountNumber: String?? = nil,
        payeeCardNumber: String?? = nil,
        payeeAccountNumber: String?? = nil,
        payeePhone: String?? = nil,
        payeeName: String?? = nil,
        amount: Int?? = nil,
        currencyAmount: String?? = nil,
        commission: [String]?? = nil
    ) -> PrepareExternalDataClass {
        return PrepareExternalDataClass(
            payerCardNumber: payerCardNumber ?? self.payerCardNumber,
            payerAccountNumber: payerAccountNumber ?? self.payerAccountNumber,
            payeeCardNumber: payeeCardNumber ?? self.payeeCardNumber,
            payeeAccountNumber: payeeAccountNumber ?? self.payeeAccountNumber,
            payeePhone: payeePhone ?? self.payeePhone,
            payeeName: payeeName ?? self.payeeName,
            amount: amount ?? self.amount,
            currencyAmount: currencyAmount ?? self.currencyAmount,
            commission: commission ?? self.commission
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
