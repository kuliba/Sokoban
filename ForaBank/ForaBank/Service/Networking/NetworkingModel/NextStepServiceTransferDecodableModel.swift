//
//  NextStepServiceTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 23.11.2021.
//

import Foundation

// MARK: - NextStepServiceTransferDecodableModel
struct NextStepServiceTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: NextStepServiceTransferDataClass?
}

// MARK: NextStepServiceTransferDecodableModel convenience initializers and mutators

extension NextStepServiceTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NextStepServiceTransferDecodableModel.self, from: data)
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
        data: NextStepServiceTransferDataClass?? = nil
    ) -> NextStepServiceTransferDecodableModel {
        return NextStepServiceTransferDecodableModel(
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

// MARK: - NextStepServiceTransferDataClass
struct NextStepServiceTransferDataClass: Codable {
    let needMake, needOTP, needSum: Bool?
    let amount: Double?
    let creditAmount: JSONNull?
    let fee: Int?
    let currencyAmount: String?
    let currencyPayer, currencyPayee, currencyRate: JSONNull?
    let debitAmount: Double?
    let payeeName, paymentOperationDetailID, documentStatus: JSONNull?
    let additionalList: [NextStepServiceTransferAdditionalList]?
    let parameterListForNextStep: [JSONAny]?
    let finalStep: Bool?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, needSum, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList, parameterListForNextStep, finalStep
    }
}

// MARK: DataClass convenience initializers and mutators

extension NextStepServiceTransferDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NextStepServiceTransferDataClass.self, from: data)
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
        needSum: Bool?? = nil,
        amount: Double?? = nil,
        creditAmount: JSONNull?? = nil,
        fee: Int?? = nil,
        currencyAmount: String?? = nil,
        currencyPayer: JSONNull?? = nil,
        currencyPayee: JSONNull?? = nil,
        currencyRate: JSONNull?? = nil,
        debitAmount: Double?? = nil,
        payeeName: JSONNull?? = nil,
        paymentOperationDetailID: JSONNull?? = nil,
        documentStatus: JSONNull?? = nil,
        additionalList: [NextStepServiceTransferAdditionalList]?? = nil,
        parameterListForNextStep: [JSONAny]?? = nil,
        finalStep: Bool?? = nil
    ) -> NextStepServiceTransferDataClass {
        return NextStepServiceTransferDataClass (
            needMake: needMake ?? self.needMake,
            needOTP: needOTP ?? self.needOTP,
            needSum: needSum ?? self.needSum,
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
            additionalList: additionalList ?? self.additionalList,
            parameterListForNextStep: parameterListForNextStep ?? self.parameterListForNextStep,
            finalStep: finalStep ?? self.finalStep
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - NextStepServiceTransferAdditionalList
struct NextStepServiceTransferAdditionalList: Codable {
    let fieldName, fieldValue, fieldTitle: String?
}

// MARK: NextStepServiceTransferAdditionalList convenience initializers and mutators

extension NextStepServiceTransferAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NextStepServiceTransferAdditionalList.self, from: data)
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
        fieldValue: String?? = nil,
        fieldTitle: String?? = nil
    ) -> NextStepServiceTransferAdditionalList {
        return NextStepServiceTransferAdditionalList (
            fieldName: fieldName ?? self.fieldName,
            fieldValue: fieldValue ?? self.fieldValue,
            fieldTitle: fieldTitle ?? self.fieldTitle
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

