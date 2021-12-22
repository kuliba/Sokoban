//
//  CreateMe2MePullDebitTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.09.2021.
//

import Foundation

// MARK: - CreateMe2MePullDebitTransferDecodableModel
struct CreateMe2MePullDebitTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreateMe2MePullDebitTransferDataClass?
}

// MARK: CreateMe2MePullDebitTransferDecodableModel convenience initializers and mutators

extension CreateMe2MePullDebitTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateMe2MePullDebitTransferDecodableModel.self, from: data)
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
        data: CreateMe2MePullDebitTransferDataClass?? = nil
    ) -> CreateMe2MePullDebitTransferDecodableModel {
        return CreateMe2MePullDebitTransferDecodableModel(
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

// MARK: - CreateMe2MePullDebitTransferDataClass
struct CreateMe2MePullDebitTransferDataClass: Codable {
    let needMake, needOTP: Bool?
    let amount: Double?
    let creditAmount: JSONNull?
    let fee: Double?
    let currencyAmount, currencyPayer, currencyPayee: String?
    let currencyRate: JSONNull?
    let debitAmount: Int?
    let payeeName: String?
    let paymentOperationDetailID: Int?
    let documentStatus: JSONNull?
    let additionalList: [CreateMe2MePullDebitTransfer]?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList
    }
}

// MARK: CreateMe2MePullDebitTransferDataClass convenience initializers and mutators

extension CreateMe2MePullDebitTransferDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateMe2MePullDebitTransferDataClass.self, from: data)
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
        fee: Double?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: String?? = nil,
        currencyPayee: String?? = nil,
        currencyRate: JSONNull?? = nil,
        debitAmount: Int?? = nil,
        payeeName: String?? = nil,
        paymentOperationDetailID: Int?? = nil,
        documentStatus: JSONNull?? = nil,
        additionalList: [CreateMe2MePullDebitTransfer]?? = nil
    ) -> CreateMe2MePullDebitTransferDataClass {
        return CreateMe2MePullDebitTransferDataClass(
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
            documentStatus: documentStatus ?? self.documentStatus,
            additionalList: additionalList ?? self.additionalList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - CreateMe2MePullDebitTransfer
struct CreateMe2MePullDebitTransfer: Codable {
    let fieldName, fieldValue: String?
}

// MARK: CreateMe2MePullDebitTransfer convenience initializers and mutators

extension CreateMe2MePullDebitTransfer {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateMe2MePullDebitTransfer.self, from: data)
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
        fieldName: String?? = nil,
        fieldValue: String?? = nil
    ) -> CreateMe2MePullDebitTransfer {
        return CreateMe2MePullDebitTransfer(
            fieldName: fieldName ?? self.fieldName,
            fieldValue: fieldValue ?? self.fieldValue
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
