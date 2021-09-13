//
//  CreateSFPTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.09.2021.
//

import Foundation

// MARK: - CreateSFPTransferDecodableModel
struct CreateSFPTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreateSFPDataClass?
}

// MARK: CreateSFPTransferDecodableModel convenience initializers and mutators

extension CreateSFPTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateSFPTransferDecodableModel.self, from: data)
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
        data: CreateSFPDataClass?? = nil
    ) -> CreateSFPTransferDecodableModel {
        return CreateSFPTransferDecodableModel(
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

// MARK: - CreateSFPDataClass
struct CreateSFPDataClass: Codable {
    let needMake, needOTP: Bool?
    let amount: Double?
    let creditAmount: String?
    let fee: Double?
    let currencyAmount, currencyPayer, currencyPayee: String?
    let currencyRate: String?
    let debitAmount: Double?
    let payeeName: String?
    let paymentOperationDetailID, documentStatus: String?
    let additionalList: [CreateSFPAdditionalList]?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList
    }
}

// MARK: DataClass convenience initializers and mutators

extension CreateSFPDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateSFPDataClass.self, from: data)
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
        fee: Double?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: String?? = nil,
        currencyPayee: String?? = nil,
        currencyRate: String?? = nil,
        debitAmount: Double?? = nil,
        payeeName: String?? = nil,
        paymentOperationDetailID: String?? = nil,
        documentStatus: String?? = nil,
        additionalList: [CreateSFPAdditionalList]?? = nil
    ) -> CreateSFPDataClass {
        return CreateSFPDataClass(
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
struct CreateSFPAdditionalList: Codable {
    let fieldName, fieldValue: String?
}

// MARK: CreateSFPAdditionalList convenience initializers and mutators

extension CreateSFPAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateSFPAdditionalList.self, from: data)
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
    ) -> CreateSFPAdditionalList {
        return CreateSFPAdditionalList(
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
