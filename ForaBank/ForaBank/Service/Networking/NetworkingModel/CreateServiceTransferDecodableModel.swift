//
//  CreateServiceTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.08.2021.
//

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
    let needMake, needOTP: JSONNull?
    let needSum: Bool?
    let amount, creditAmount, fee, currencyAmount: JSONNull?
    let currencyPayer, currencyPayee, currencyRate, debitAmount: JSONNull?
    let payeeName, paymentOperationDetailID, documentStatus: JSONNull?
    let additionalList: [CreateServiceTransferAdditionalList]?
    let parameterListForNextStep: [ParameterListForNextStep]?
    let finalStep: Bool?

    enum CodingKeys: String, CodingKey {
        case needMake, needOTP, needSum, amount, creditAmount, fee, currencyAmount, currencyPayer, currencyPayee, currencyRate, debitAmount, payeeName
        case paymentOperationDetailID = "paymentOperationDetailId"
        case documentStatus, additionalList, parameterListForNextStep, finalStep
    }
}

// MARK: DataClass convenience initializers and mutators

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
        needMake: JSONNull?? = nil,
        needOTP: JSONNull?? = nil,
        needSum: Bool?? = nil,
        amount: JSONNull?? = nil,
        creditAmount: JSONNull?? = nil,
        fee: JSONNull?? = nil,
        currencyAmount: JSONNull?? = nil,
        currencyPayer: JSONNull?? = nil,
        currencyPayee: JSONNull?? = nil,
        currencyRate: JSONNull?? = nil,
        debitAmount: JSONNull?? = nil,
        payeeName: JSONNull?? = nil,
        paymentOperationDetailID: JSONNull?? = nil,
        documentStatus: JSONNull?? = nil,
        additionalList: [CreateServiceTransferAdditionalList]?? = nil,
        parameterListForNextStep: [ParameterListForNextStep]?? = nil,
        finalStep: Bool?? = nil
    ) -> CreateServiceTransferDataClass {
        return CreateServiceTransferDataClass(
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

// MARK: - CreateServiceTransferAdditionalList
struct CreateServiceTransferAdditionalList: Codable {
    let fieldName, fieldValue, fieldTitle: String?
}

// MARK: CreateServiceTransferAdditionalList convenience initializers and mutators

extension CreateServiceTransferAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreateServiceTransferAdditionalList.self, from: data)
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
    ) -> CreateServiceTransferAdditionalList {
        return CreateServiceTransferAdditionalList(
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

// MARK: - ParameterListForNextStep
struct ParameterListForNextStep: Codable {
    let id: String?
    let order: Int?
    let title: String?
    let subTitle: String?
    let viewType, dataType, type: String?
    let mask: String?
    let regExp: String?
    let maxLength, minLength: String?
    let rawLength: Int?
    let isRequired: Bool?
}

// MARK: ParameterListForNextStep convenience initializers and mutators

extension ParameterListForNextStep {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ParameterListForNextStep.self, from: data)
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
        id: String?? = nil,
        order: Int?? = nil,
        title: String?? = nil,
        subTitle: String?? = nil,
        viewType: String?? = nil,
        dataType: String?? = nil,
        type: String?? = nil,
        mask: String?? = nil,
        regExp: String?? = nil,
        maxLength: String?? = nil,
        minLength: String?? = nil,
        rawLength: Int?? = nil,
        isRequired: Bool?? = nil
    ) -> ParameterListForNextStep {
        return ParameterListForNextStep(
            id: id ?? self.id,
            order: order ?? self.order,
            title: title ?? self.title,
            subTitle: subTitle ?? self.subTitle,
            viewType: viewType ?? self.viewType,
            dataType: dataType ?? self.dataType,
            type: type ?? self.type,
            mask: mask ?? self.mask,
            regExp: regExp ?? self.regExp,
            maxLength: maxLength ?? self.maxLength,
            minLength: minLength ?? self.minLength,
            rawLength: rawLength ?? self.rawLength,
            isRequired: isRequired ?? self.isRequired
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
