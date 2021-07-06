//
//  PrepareExternalDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let prepareExternalDecodableModel = try PrepareExternalDecodableModel(json)

import Foundation

// MARK: - PrepareExternalDecodableModel
struct PrepareExternalDecodableModel: Codable, NetworkModelProtocol {
    let data: PrepareExternalDataClass?
    let errorMessage: String?
    let statusCode: Int?
}

// MARK: PrepareExternalDecodableModel convenience initializers and mutators

extension PrepareExternalDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrepareExternalDecodableModel.self, from: data)
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
        data: PrepareExternalDataClass?? = nil,
        errorMessage: String?? = nil,
        statusCode: Int?? = nil
    ) -> PrepareExternalDecodableModel {
        return PrepareExternalDecodableModel(
            data: data ?? self.data,
            errorMessage: errorMessage ?? self.errorMessage,
            statusCode: statusCode ?? self.statusCode
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

// MARK: - PrepareExternalDataClass
struct PrepareExternalDataClass: Codable {
    let amount: Int?
    let bcc, comment, compilerStatus, date: String?
    let oktmo: String?
    let payeeAccountID: Int?
    let payeeAccountNumber, payeeBankBIC, payeeCardNumber: String?
    let payeeCardNumberID: Int?
    let payeeINN, payeeKPP, payeeName: String?
    let payerAccountID: Int?
    let payerCardNumber: String?
    let payerCardNumberID: Int?
    let payerINN, taxDate, taxDocumentNumber, taxDocumentType: String?
    let taxPeriod, taxReason, uin: String?
}

// MARK: DataClass convenience initializers and mutators

extension PrepareExternalDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PrepareExternalDataClass.self, from: data)
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
        amount: Int?? = nil,
        bcc: String?? = nil,
        comment: String?? = nil,
        compilerStatus: String?? = nil,
        date: String?? = nil,
        oktmo: String?? = nil,
        payeeAccountID: Int?? = nil,
        payeeAccountNumber: String?? = nil,
        payeeBankBIC: String?? = nil,
        payeeCardNumber: String?? = nil,
        payeeCardNumberID: Int?? = nil,
        payeeINN: String?? = nil,
        payeeKPP: String?? = nil,
        payeeName: String?? = nil,
        payerAccountID: Int?? = nil,
        payerCardNumber: String?? = nil,
        payerCardNumberID: Int?? = nil,
        payerINN: String?? = nil,
        taxDate: String?? = nil,
        taxDocumentNumber: String?? = nil,
        taxDocumentType: String?? = nil,
        taxPeriod: String?? = nil,
        taxReason: String?? = nil,
        uin: String?? = nil
    ) -> PrepareExternalDataClass {
        return PrepareExternalDataClass(
            amount: amount ?? self.amount,
            bcc: bcc ?? self.bcc,
            comment: comment ?? self.comment,
            compilerStatus: compilerStatus ?? self.compilerStatus,
            date: date ?? self.date,
            oktmo: oktmo ?? self.oktmo,
            payeeAccountID: payeeAccountID ?? self.payeeAccountID,
            payeeAccountNumber: payeeAccountNumber ?? self.payeeAccountNumber,
            payeeBankBIC: payeeBankBIC ?? self.payeeBankBIC,
            payeeCardNumber: payeeCardNumber ?? self.payeeCardNumber,
            payeeCardNumberID: payeeCardNumberID ?? self.payeeCardNumberID,
            payeeINN: payeeINN ?? self.payeeINN,
            payeeKPP: payeeKPP ?? self.payeeKPP,
            payeeName: payeeName ?? self.payeeName,
            payerAccountID: payerAccountID ?? self.payerAccountID,
            payerCardNumber: payerCardNumber ?? self.payerCardNumber,
            payerCardNumberID: payerCardNumberID ?? self.payerCardNumberID,
            payerINN: payerINN ?? self.payerINN,
            taxDate: taxDate ?? self.taxDate,
            taxDocumentNumber: taxDocumentNumber ?? self.taxDocumentNumber,
            taxDocumentType: taxDocumentType ?? self.taxDocumentType,
            taxPeriod: taxPeriod ?? self.taxPeriod,
            taxReason: taxReason ?? self.taxReason,
            uin: uin ?? self.uin
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
