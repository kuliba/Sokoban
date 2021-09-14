//
//  GetCardStatementDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation

// MARK: - GetCardStatementDecodableModel
struct GetCardStatementDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetCardStatementDataClass?
}

// MARK: GetCardStatementDecodableModel convenience initializers and mutators

extension GetCardStatementDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCardStatementDecodableModel.self, from: data)
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
        data: GetCardStatementDataClass?? = nil
    ) -> GetCardStatementDecodableModel {
        return GetCardStatementDecodableModel(
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

// MARK: - GetCardStatementDataClass
struct GetCardStatementDataClass: Codable {
    let accountID, date: Int?
    let operationType: String?
    let amount: Int?
    let comment: String?
    let documentID: Int?
    let accountNumber: String?
    let currencyCodeNumeric: Int?
    let name: String?
}

// MARK: DataClass convenience initializers and mutators

extension GetCardStatementDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCardStatementDataClass.self, from: data)
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
        accountID: Int?? = nil,
        date: Int?? = nil,
        operationType: String?? = nil,
        amount: Int?? = nil,
        comment: String?? = nil,
        documentID: Int?? = nil,
        accountNumber: String?? = nil,
        currencyCodeNumeric: Int?? = nil,
        name: String?? = nil
    ) -> GetCardStatementDataClass {
        return GetCardStatementDataClass(
            accountID: accountID ?? self.accountID,
            date: date ?? self.date,
            operationType: operationType ?? self.operationType,
            amount: amount ?? self.amount,
            comment: comment ?? self.comment,
            documentID: documentID ?? self.documentID,
            accountNumber: accountNumber ?? self.accountNumber,
            currencyCodeNumeric: currencyCodeNumeric ?? self.currencyCodeNumeric,
            name: name ?? self.name
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
