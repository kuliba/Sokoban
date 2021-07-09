//
//  CreatTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.06.2021.
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let creatTransferDecodableModel = try CreatTransferDecodableModel(json)

import Foundation

// MARK: - CreatTransferDecodableModel
struct CreatTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreatTransferDataClass?
}

// MARK: CreatTransferDecodableModel convenience initializers and mutators

extension CreatTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreatTransferDecodableModel.self, from: data)
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
        data: CreatTransferDataClass?? = nil
    ) -> CreatTransferDecodableModel {
        return CreatTransferDecodableModel(
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

// MARK: - DataClass
struct CreatTransferDataClass: Codable {
    let check: Bool?
    let amount, comment, currencyAmount: String?
    let payer, payeeInternal: Paye?
    let payeeExternal: PayeeExternal?
}

// MARK: DataClass convenience initializers and mutators

extension CreatTransferDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreatTransferDataClass.self, from: data)
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
        check: Bool?? = nil,
        amount: String?? = nil,
        comment: String?? = nil,
        currencyAmount: String?? = nil,
        payer: Paye?? = nil,
        payeeInternal: Paye?? = nil,
        payeeExternal: PayeeExternal?? = nil
    ) -> CreatTransferDataClass {
        return CreatTransferDataClass(
            check: check ?? self.check,
            amount: amount ?? self.amount,
            comment: comment ?? self.comment,
            currencyAmount: currencyAmount ?? self.currencyAmount,
            payer: payer ?? self.payer,
            payeeInternal: payeeInternal ?? self.payeeInternal,
            payeeExternal: payeeExternal ?? self.payeeExternal
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - PayeeExternal
struct PayeeExternal: Codable {
    let cardID, cardNumber, accountID, accountNumber: String?
    let compilerStatus, date, name, bankBIC: String?
    let inn, kpp: String?
    let tax: Tax?

    enum CodingKeys: String, CodingKey {
        case cardID = "cardId"
        case cardNumber
        case accountID = "accountId"
        case accountNumber, compilerStatus, date, name, bankBIC
        case inn = "INN"
        case kpp = "KPP"
        case tax
    }
}

// MARK: PayeeExternal convenience initializers and mutators

extension PayeeExternal {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PayeeExternal.self, from: data)
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
        cardID: String?? = nil,
        cardNumber: String?? = nil,
        accountID: String?? = nil,
        accountNumber: String?? = nil,
        compilerStatus: String?? = nil,
        date: String?? = nil,
        name: String?? = nil,
        bankBIC: String?? = nil,
        inn: String?? = nil,
        kpp: String?? = nil,
        tax: Tax?? = nil
    ) -> PayeeExternal {
        return PayeeExternal(
            cardID: cardID ?? self.cardID,
            cardNumber: cardNumber ?? self.cardNumber,
            accountID: accountID ?? self.accountID,
            accountNumber: accountNumber ?? self.accountNumber,
            compilerStatus: compilerStatus ?? self.compilerStatus,
            date: date ?? self.date,
            name: name ?? self.name,
            bankBIC: bankBIC ?? self.bankBIC,
            inn: inn ?? self.inn,
            kpp: kpp ?? self.kpp,
            tax: tax ?? self.tax
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


// MARK: - Tax
struct Tax: Codable {
    let oktmo, uin, documentNumber, bcc: String?
    let period, date, reason, documentType: String?
}

// MARK: Tax convenience initializers and mutators

extension Tax {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Tax.self, from: data)
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
        oktmo: String?? = nil,
        uin: String?? = nil,
        documentNumber: String?? = nil,
        bcc: String?? = nil,
        period: String?? = nil,
        date: String?? = nil,
        reason: String?? = nil,
        documentType: String?? = nil
    ) -> Tax {
        return Tax(
            oktmo: oktmo ?? self.oktmo,
            uin: uin ?? self.uin,
            documentNumber: documentNumber ?? self.documentNumber,
            bcc: bcc ?? self.bcc,
            period: period ?? self.period,
            date: date ?? self.date,
            reason: reason ?? self.reason,
            documentType: documentType ?? self.documentType
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Paye
struct Paye: Codable {
    let cardID, cardNumber, accountID, accountNumber: String?
    let phoneNumber, productCustomName, inn: String?

    enum CodingKeys: String, CodingKey {
        case cardID = "cardId"
        case cardNumber
        case accountID = "accountId"
        case accountNumber, phoneNumber, productCustomName
        case inn = "INN"
    }
}

// MARK: Paye convenience initializers and mutators

extension Paye {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Paye.self, from: data)
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
        cardID: String?? = nil,
        cardNumber: String?? = nil,
        accountID: String?? = nil,
        accountNumber: String?? = nil,
        phoneNumber: String?? = nil,
        productCustomName: String?? = nil,
        inn: String?? = nil
    ) -> Paye {
        return Paye(
            cardID: cardID ?? self.cardID,
            cardNumber: cardNumber ?? self.cardNumber,
            accountID: accountID ?? self.accountID,
            accountNumber: accountNumber ?? self.accountNumber,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            productCustomName: productCustomName ?? self.productCustomName,
            inn: inn ?? self.inn
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
