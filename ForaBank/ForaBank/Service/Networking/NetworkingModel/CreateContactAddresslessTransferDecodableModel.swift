//
//  CreateContactAddresslessTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.08.2021.
//

import Foundation

// MARK: - CreateContactAddresslessTransferDecodableModel
struct CreateContactAddresslessTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreateContactAddresslessDataClass?
}

// MARK: CreateContactAddresslessTransferDecodableModel convenience initializers and mutators

extension CreateContactAddresslessTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateContactAddresslessTransferDecodableModel.self, from: data)
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
        data: CreateContactAddresslessDataClass?? = nil
    ) -> CreateContactAddresslessTransferDecodableModel {
        return CreateContactAddresslessTransferDecodableModel(
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

// MARK: - CreateContactAddresslessDataClass
struct CreateContactAddresslessDataClass: Codable {
    let needMake, needOTP: Bool?
    let amount: Double?
    let creditAmount: JSONNull?
    let fee: Double?
    let currencyAmount, currencyPayer, currencyPayee: String?
    let currencyRate: JSONNull?
    let debitAmount: Double?
    let payeeName: String?
    let paymentOperationDetailID: Int?
    let documentStatus: JSONNull?
    let additionalList: [CreateAdditionalList]?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList
    }
}

// MARK: DataClass convenience initializers and mutators

extension CreateContactAddresslessDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateContactAddresslessDataClass.self, from: data)
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
        debitAmount: Double?? = nil,
        payeeName: String?? = nil,
        paymentOperationDetailID: Int?? = nil,
        documentStatus: JSONNull?? = nil,
        additionalList: [CreateAdditionalList]?? = nil
    ) -> CreateContactAddresslessDataClass {
        return CreateContactAddresslessDataClass(
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
struct CreateAdditionalList: Codable {
    let fieldName, fieldValue: String?
}

// MARK: AdditionalList convenience initializers and mutators

extension CreateAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateAdditionalList.self, from: data)
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
    ) -> CreateAdditionalList {
        return CreateAdditionalList(
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
