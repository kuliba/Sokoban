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

// MARK: - DataClass
struct PrepareExternalDataClass: Codable {
    let payerCardNumber, payerAccountNumber, payeeCardNumber, payeeAccountNumber: String?
    let payeePhone, payeeName: String?
    let amount, debitAmount: Int?
    let currencyAmount, currencyPayer, currencyPayee: String?
    let currencyRate, creditAmount: Int?
    let commission: [PrepareExternalCommission]?
}

// MARK: PrepareExternal convenience initializers and mutators

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
        debitAmount: Int?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: String?? = nil,
        currencyPayee: String?? = nil,
        currencyRate: Int?? = nil,
        creditAmount: Int?? = nil,
        commission: [PrepareExternalCommission]?? = nil
    ) -> PrepareExternalDataClass {
        return PrepareExternalDataClass(
            payerCardNumber: payerCardNumber ?? self.payerCardNumber,
            payerAccountNumber: payerAccountNumber ?? self.payerAccountNumber,
            payeeCardNumber: payeeCardNumber ?? self.payeeCardNumber,
            payeeAccountNumber: payeeAccountNumber ?? self.payeeAccountNumber,
            payeePhone: payeePhone ?? self.payeePhone,
            payeeName: payeeName ?? self.payeeName,
            amount: amount ?? self.amount,
            debitAmount: debitAmount ?? self.debitAmount,
            currencyAmount: currencyAmount ?? self.currencyAmount,
            currencyPayer: currencyPayer ?? self.currencyPayer,
            currencyPayee: currencyPayee ?? self.currencyPayee,
            currencyRate: currencyRate ?? self.currencyRate,
            creditAmount: creditAmount ?? self.creditAmount,
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


// MARK: - PrepareExternalCommission
struct PrepareExternalCommission: Codable {
    let amount, rate: Int?
    let commissionDescription: String?

    enum CodingKeys: String, CodingKey {
        case amount, rate
        case commissionDescription = "description"
    }
}

// MARK: Commission convenience initializers and mutators

extension PrepareExternalCommission {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrepareExternalCommission.self, from: data)
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
        amount: Int?? = nil,
        rate: Int?? = nil,
        commissionDescription: String?? = nil
    ) -> PrepareExternalCommission {
        return PrepareExternalCommission(
            amount: amount ?? self.amount,
            rate: rate ?? self.rate,
            commissionDescription: commissionDescription ?? self.commissionDescription
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
