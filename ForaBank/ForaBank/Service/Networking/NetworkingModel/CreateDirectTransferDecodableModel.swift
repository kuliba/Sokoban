//
//  CreateDirectTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.08.2021.
//

import Foundation

// MARK: - CreateDirectTransferDecodableModel
struct CreateDirectTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreateDirectDataClass?
}

// MARK: CreateDirectTransferDecodableModel convenience initializers and mutators

extension CreateDirectTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateDirectTransferDecodableModel.self, from: data)
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
        data: CreateDirectDataClass?? = nil
    ) -> CreateDirectTransferDecodableModel {
        return CreateDirectTransferDecodableModel(
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

// MARK: - CreateDirectDataClass
struct CreateDirectDataClass: Codable {
    let needMake, needOTP: Bool?
    let amount, creditAmount, fee: Int?
    let currencyAmount, currencyPayer, currencyPayee: String?
    let currencyRate: JSONNull?
    let debitAmount: Int?
    let payeeName: String?
    let paymentOperationDetailID, documentStatus: JSONNull?
    let additionalList: [AdditionalList]?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList
    }
}

// MARK: CreateDirectDataClass convenience initializers and mutators

extension CreateDirectDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateDirectDataClass.self, from: data)
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
        creditAmount: Int?? = nil,
        fee: Int?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: String?? = nil,
        currencyPayee: String?? = nil,
        currencyRate: JSONNull?? = nil,
        debitAmount: Int?? = nil,
        payeeName: String?? = nil,
        paymentOperationDetailID: JSONNull?? = nil,
        documentStatus: JSONNull?? = nil,
        additionalList: [AdditionalList]?? = nil
    ) -> CreateDirectDataClass {
        return CreateDirectDataClass(
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

// MARK: - AdditionalList
struct AdditionalList: Codable {
    let fieldName, fieldValue: String?
}

// MARK: AdditionalList convenience initializers and mutators

extension AdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AdditionalList.self, from: data)
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
    ) -> AdditionalList {
        return AdditionalList(
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
