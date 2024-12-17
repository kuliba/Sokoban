//
//  CreateMobileTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.09.2021.
//

import Foundation

// MARK: - CreateMobileTransferDecodableModel
struct CreateMobileTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreateMobileTransferDataClass?
}

// MARK: CreateMobileTransferDecodableModel convenience initializers and mutators

extension CreateMobileTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateMobileTransferDecodableModel.self, from: data)
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
        data: CreateMobileTransferDataClass?? = nil
    ) -> CreateMobileTransferDecodableModel {
        return CreateMobileTransferDecodableModel(
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


// MARK: - CreateMobileTransferDataClass
struct CreateMobileTransferDataClass: Codable {
    let needMake, needOTP: Bool?
    let amount: Double?
    let creditAmount: String?
    let fee: Int?
    let currencyAmount, currencyPayer, currencyPayee, currencyRate: String?
    let debitAmount: Double?
    let payeeName: JSONNull?
    let paymentOperationDetailID: Int?
    let documentStatus: String?
    let additionalList: [CreateMobileTransferAdditionalList]?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList
    }
}

// MARK: CreateMobileTransferDataClass convenience initializers and mutators

extension CreateMobileTransferDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateMobileTransferDataClass.self, from: data)
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
        creditAmount: String?? = nil,
        fee: Int?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: String?? = nil,
        currencyPayee: String?? = nil,
        currencyRate: String?? = nil,
        debitAmount: Double?? = nil,
        payeeName: JSONNull?? = nil,
        paymentOperationDetailID: Int?? = nil,
        documentStatus: String?? = nil,
        additionalList: [CreateMobileTransferAdditionalList]?? = nil
    ) -> CreateMobileTransferDataClass {
        return CreateMobileTransferDataClass(
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

// MARK: - CreateMobileTransferAdditionalList
struct CreateMobileTransferAdditionalList: Codable {
    let fieldName, fieldValue: String?
}

// MARK: CreateMobileTransferAdditionalList convenience initializers and mutators

extension CreateMobileTransferAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateMobileTransferAdditionalList.self, from: data)
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
    ) -> CreateMobileTransferAdditionalList {
        return CreateMobileTransferAdditionalList(
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
