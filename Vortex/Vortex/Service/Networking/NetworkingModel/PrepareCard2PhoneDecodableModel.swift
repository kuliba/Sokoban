//
//  PrepareCard2PhoneDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let prepareCard2PhoneDecodableModel = try PrepareCard2PhoneDecodableModel(json)

import Foundation

// MARK: - PrepareCard2PhoneDecodableModel
struct PrepareCard2PhoneDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: PrepareCardDataClass?
}

// MARK: PrepareCard2PhoneDecodableModel convenience initializers and mutators

extension PrepareCard2PhoneDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrepareCard2PhoneDecodableModel.self, from: data)
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
        data: PrepareCardDataClass?? = nil
    ) -> PrepareCard2PhoneDecodableModel {
        return PrepareCard2PhoneDecodableModel(
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

// MARK: - PrepareCardDataClass
struct PrepareCardDataClass: Codable {
    let payerCardNumber, payerAccountNumber, payeeCardNumber, payeeAccountNumber: String?
    let payeePhone, payeeName: String?
    let amount: Int?
    let currencyAmount: String?
    let commission: [JSONAny]?
}

// MARK: DataClass convenience initializers and mutators

extension PrepareCardDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrepareCardDataClass.self, from: data)
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
        commission: [JSONAny]?? = nil
    ) -> PrepareCardDataClass {
        return PrepareCardDataClass(
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
