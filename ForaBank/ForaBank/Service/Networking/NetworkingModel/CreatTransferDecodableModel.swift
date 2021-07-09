//
//  CreatTransferDecodableModel.swift
//  ForaBank
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

// MARK: - CreatTransferDataClass
struct CreatTransferDataClass: Codable {
    let needMake, needOTP: Bool?
    let amount: Double?
    let creditAmount: JSONNull?
    let fee: Int?
    let currencyAmount, currencyPayer, currencyPayee: String?
    let currencyRate: JSONNull?
    let debitAmount: Double?
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
        needMake: Bool?? = nil,
        needOTP: Bool?? = nil,
        amount: Double?? = nil,
        creditAmount: JSONNull?? = nil,
        fee: Int?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: String?? = nil,
        currencyPayee: String?? = nil,
        currencyRate: JSONNull?? = nil,
        debitAmount: Double?? = nil
    ) -> CreatTransferDataClass {
        return CreatTransferDataClass(
            needMake: needMake ?? self.needMake,
            needOTP: needOTP ?? self.needOTP,
            amount: amount ?? self.amount,
            creditAmount: creditAmount ?? self.creditAmount,
            fee: fee ?? self.fee,
            currencyAmount: currencyAmount ?? self.currencyAmount,
            currencyPayer: currencyPayer ?? self.currencyPayer,
            currencyPayee: currencyPayee ?? self.currencyPayee,
            currencyRate: currencyRate ?? self.currencyRate,
            debitAmount: debitAmount ?? self.debitAmount
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
