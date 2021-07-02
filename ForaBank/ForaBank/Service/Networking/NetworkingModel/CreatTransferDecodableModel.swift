//
//  CreatTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let creatTransferDecodableModel = try CreatTransferDecodableModel(json)

import Foundation

// MARK: - CreatTransferDecodableModel
struct CreatTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreatTransferDataClass?
}

// MARK: CreatTransferDecodableModel convenience initializers and mutators

extension CreatTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreatTransferDecodableModel.self, from: data)
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
        data: CreatTransferDataClass?? = nil
    ) -> CreatTransferDecodableModel {
        return CreatTransferDecodableModel(
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

// MARK: - CreatTransferDataClass
struct CreatTransferDataClass: Codable {
    let amount, creditAmount, currencyRate, debitAmount, fee: Double?
    let needMake: Bool?
    let currencyAmount, currencyPayer, currencyPayee: String?
}

// MARK: DataClass convenience initializers and mutators

extension CreatTransferDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreatTransferDataClass.self, from: data)
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
        amount: Double?? = nil,
        creditAmount: Double?? = nil,
        currencyRate: Double?? = nil,
        debitAmount: Double?? = nil,
        fee: Double?? = nil,
        needMake: Bool?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: String?? = nil,
        currencyPayee: String?? = nil
    ) -> CreatTransferDataClass {
        return CreatTransferDataClass(
            amount: amount ?? self.amount,
            creditAmount: creditAmount ?? self.creditAmount,
            currencyRate: currencyRate ?? self.currencyRate,
            debitAmount: debitAmount ?? self.debitAmount,
            fee: fee ?? self.fee,
            needMake: needMake ?? self.needMake,
            currencyAmount: currencyAmount ?? self.currencyAmount,
            currencyPayer: currencyPayer ?? self.currencyPayer,
            currencyPayee: currencyPayee ?? self.currencyPayee
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
