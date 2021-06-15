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
    let errorMessage: JSONNull?
    let data: AnywayPaymentDataClass?
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
        errorMessage: JSONNull?? = nil,
        data: AnywayPaymentDataClass?? = nil
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
struct AnywayPaymentDataClass: Codable {
    let paymentOperationDetailID: JSONNull?
    let listInputs: [ListInput]?
    let error: String?
    let errorMessage: JSONNull?
    let finalStep: Int?
    let id: String?
    let amount, commission: JSONNull?
    let nextStep: Int?

    enum CodingKeys: String, CodingKey {
        case paymentOperationDetailID = "paymentOperationDetailId"
        case listInputs, error, errorMessage, finalStep, id, amount, commission, nextStep
    }
}

// MARK: DataClass convenience initializers and mutators

extension AnywayPaymentDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AnywayPaymentDataClass.self, from: data)
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
        errorMessage: JSONNull?? = nil,
        finalStep: Int?? = nil,
        id: String?? = nil,
        amount: JSONNull?? = nil,
        commission: JSONNull?? = nil,
        nextStep: Int?? = nil
    ) -> AnywayPaymentDataClass {
        return AnywayPaymentDataClass (
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

// MARK: - ListInput
struct ListInput: Codable {
    let content: [String]?
    let id: String?
    let order: Int?
    let paramGroup: JSONNull?
    let name: String?
    let type: TypeEnum?
    let dataType: String?
    let hint, mask, regExp, min: JSONNull?
    let max, sum: JSONNull?
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
        type: TypeEnum?? = nil,
        dataType: String?? = nil,
        hint: JSONNull?? = nil,
        mask: JSONNull?? = nil,
        regExp: JSONNull?? = nil,
        min: JSONNull?? = nil,
        max: JSONNull?? = nil,
        sum: JSONNull?? = nil,
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

// TypeEnum.swift

enum TypeEnum: String, Codable {
    case input = "Input"
    case select = "Select"
}

