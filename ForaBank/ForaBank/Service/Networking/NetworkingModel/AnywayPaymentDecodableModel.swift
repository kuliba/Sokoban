//
//  AnywayPaymentDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let anywayPaymentDecodableModel = try AnywayPaymentDecodableModel(json)

import Foundation

// MARK: - AnywayPaymentDecodableModel
struct AnywayPaymentDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: AnywayPayment?
}

// MARK: AnywayPaymentDecodableModel convenience initializers and mutators

extension AnywayPaymentDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AnywayPaymentDecodableModel.self, from: data)
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
        data: AnywayPayment?? = nil
    ) -> AnywayPaymentDecodableModel {
        return AnywayPaymentDecodableModel(
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

import Foundation

// MARK: - DataClass
struct AnywayPayment: Codable {
    let paymentOperationDetailID: JSONNull?
    let listInputs: [ListInput]?
    let error: String?
    let errorMessage: String?
    let finalStep: Int?
    let id: String?
    let amount: Double?
    let commission: Double?
    let nextStep: Int?

    enum CodingKeys: String, CodingKey {
        case paymentOperationDetailID = "paymentOperationDetailId"
        case listInputs, error, errorMessage, finalStep, id, amount, commission, nextStep
    }
}

// MARK: DataClass convenience initializers and mutators

extension AnywayPayment {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AnywayPayment.self, from: data)
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
        paymentOperationDetailID: JSONNull?? = nil,
        listInputs: [ListInput]?? = nil,
        error: String?? = nil,
        errorMessage: String?? = nil,
        finalStep: Int?? = nil,
        id: String?? = nil,
        amount: Double?? = nil,
        commission: Double?? = nil,
        nextStep: Int?? = nil
    ) -> AnywayPayment {
        return AnywayPayment(
            paymentOperationDetailID: paymentOperationDetailID ?? self.paymentOperationDetailID,
            listInputs: listInputs ?? self.listInputs,
            error: error ?? self.error,
            errorMessage: errorMessage ?? self.errorMessage,
            finalStep: finalStep ?? self.finalStep,
            id: id ?? self.id,
            amount: amount ?? self.amount,
            commission: commission ?? self.commission,
            nextStep: nextStep ?? self.nextStep
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// ListInput.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let listInput = try ListInput(json)

import Foundation

// MARK: - ListInput
struct ListInput: Codable {
    let content: [String]?
    let id: String?
    let order: Int?
    let paramGroup: JSONNull?
    let name, type, dataType: String?
    let hint: String?
    let mask, regExp: String?
    let min, max: Int?
    let sum: Bool?
    let rightNum: Int?
    let note: JSONNull?
    let print, readOnly, visible, req: Bool?
    let onChange: JSONNull?
    let template: Bool?
}

// MARK: ListInput convenience initializers and mutators

extension ListInput {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ListInput.self, from: data)
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
        content: [String]?? = nil,
        id: String?? = nil,
        order: Int?? = nil,
        paramGroup: JSONNull?? = nil,
        name: String?? = nil,
        type: String?? = nil,
        dataType: String?? = nil,
        hint: String?? = nil,
        mask: String?? = nil,
        regExp: String?? = nil,
        min: Int?? = nil,
        max: Int?? = nil,
        sum: Bool?? = nil,
        rightNum: Int?? = nil,
        note: JSONNull?? = nil,
        print: Bool?? = nil,
        readOnly: Bool?? = nil,
        visible: Bool?? = nil,
        req: Bool?? = nil,
        onChange: JSONNull?? = nil,
        template: Bool?? = nil
    ) -> ListInput {
        return ListInput(
            content: content ?? self.content,
            id: id ?? self.id,
            order: order ?? self.order,
            paramGroup: paramGroup ?? self.paramGroup,
            name: name ?? self.name,
            type: type ?? self.type,
            dataType: dataType ?? self.dataType,
            hint: hint ?? self.hint,
            mask: mask ?? self.mask,
            regExp: regExp ?? self.regExp,
            min: min ?? self.min,
            max: max ?? self.max,
            sum: sum ?? self.sum,
            rightNum: rightNum ?? self.rightNum,
            note: note ?? self.note,
            print: print ?? self.print,
            readOnly: readOnly ?? self.readOnly,
            visible: visible ?? self.visible,
            req: req ?? self.req,
            onChange: onChange ?? self.onChange,
            template: template ?? self.template
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
