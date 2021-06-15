//
//  AnywayPaymentMakeDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let anywayPaymentMakeDecodableModel = try AnywayPaymentMakeDecodableModel(json)

import Foundation

// MARK: - AnywayPaymentMakeDecodableModel
struct AnywayPaymentMakeDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: AnywayPaymentMake?
}

// MARK: AnywayPaymentMakeDecodableModel convenience initializers and mutators

extension AnywayPaymentMakeDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AnywayPaymentMakeDecodableModel.self, from: data)
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
        data: AnywayPaymentMake?? = nil
    ) -> AnywayPaymentMakeDecodableModel {
        return AnywayPaymentMakeDecodableModel(
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
struct AnywayPaymentMake: Codable {
    let paymentOperationDetailID: Int?
    let listInputs: JSONNull?
    let error, errorMessage: String?
    let finalStep: Int?
    let id: String?
    let amount, commission: Int?
    let nextStep: JSONNull?

    enum CodingKeys: String, CodingKey {
        case paymentOperationDetailID = "paymentOperationDetailId"
        case listInputs, error, errorMessage, finalStep, id, amount, commission, nextStep
    }
}

// MARK: DataClass convenience initializers and mutators

extension AnywayPaymentMake {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AnywayPaymentMake.self, from: data)
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
        paymentOperationDetailID: Int?? = nil,
        listInputs: JSONNull?? = nil,
        error: String?? = nil,
        errorMessage: String?? = nil,
        finalStep: Int?? = nil,
        id: String?? = nil,
        amount: Int?? = nil,
        commission: Int?? = nil,
        nextStep: JSONNull?? = nil
    ) -> AnywayPaymentMake {
        return AnywayPaymentMake (
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
