//
//  CreateServiceTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.08.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let createServiceTransferDecodableModel = try CreateServiceTransferDecodableModel(json)

import Foundation

// MARK: - CreateServiceTransferDecodableModel
struct CreateServiceTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreateServiceTransferDataClass?
}

// MARK: CreateServiceTransferDecodableModel convenience initializers and mutators

extension CreateServiceTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateServiceTransferDecodableModel.self, from: data)
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
        data: CreateServiceTransferDataClass?? = nil
    ) -> CreateServiceTransferDecodableModel {
        return CreateServiceTransferDecodableModel(
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

// MARK: - CreateServiceTransferDataClass
struct CreateServiceTransferDataClass: Codable {
    let needMake, needOTP: Bool?
    let amount: Int?
    let creditAmount: JSONNull?
    let fee: Int?
    let currencyAmount, currencyPayer, currencyPayee, currencyRate: JSONNull?
    let debitAmount: Int?
    let payeeName, paymentOperationDetailID, documentStatus: JSONNull?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus
    }
}

// MARK: CreateServiceTransferDataClass convenience initializers and mutators

extension CreateServiceTransferDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateServiceTransferDataClass.self, from: data)
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
        amount: Int?? = nil,
        creditAmount: JSONNull?? = nil,
        fee: Int?? = nil,
        currencyAmount: JSONNull?? = nil,
        currencyPayer: JSONNull?? = nil,
        currencyPayee: JSONNull?? = nil,
        currencyRate: JSONNull?? = nil,
        debitAmount: Int?? = nil,
        payeeName: JSONNull?? = nil,
        paymentOperationDetailID: JSONNull?? = nil,
        documentStatus: JSONNull?? = nil
    ) -> CreateServiceTransferDataClass {
        return CreateServiceTransferDataClass(
            needMake: needMake ?? self.needMake,
            needOTP: needOTP ?? self.needOTP,
            amount: amount ?? self.amount,
            creditAmount: creditAmount ?? self.creditAmount,
            fee: fee ?? self.fee,
            currencyAmount: currencyAmount ?? self.currencyAmount,
            currencyPayer: currencyPayer ?? self.currencyPayer,
            currencyPayee: currencyPayee ?? self.currencyPayee,
            currencyRate: currencyRate ?? self.currencyRate,
            debitAmount: debitAmount ?? self.debitAmount,
            payeeName: payeeName ?? self.payeeName,
            paymentOperationDetailID: paymentOperationDetailID ?? self.paymentOperationDetailID,
            documentStatus: documentStatus ?? self.documentStatus
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
