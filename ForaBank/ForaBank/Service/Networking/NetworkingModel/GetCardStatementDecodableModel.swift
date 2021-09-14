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
    let operationType, comment, accountNumber: String?
    let accountID, date, documentID, currencyCodeNumeric: Int?
    let amount: Float?
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
        operationType: String?? = nil,
        comment: String?? = nil,
        accountNumber: String?? = nil,
        accountID: Int?? = nil,
        date: Int?? = nil,
        documentID: Int?? = nil,
        currencyCodeNumeric: Int?? = nil,
        amount: Float?? = nil
    ) -> GetCardStatementDataClass {
        return GetCardStatementDataClass(
            operationType: operationType ?? self.operationType,
            comment: comment ?? self.comment,
            accountNumber: accountNumber ?? self.accountNumber,
            accountID: accountID ?? self.accountID,
            date: date ?? self.date,
            documentID: documentID ?? self.documentID,
            currencyCodeNumeric: currencyCodeNumeric ?? self.currencyCodeNumeric,
            amount: amount ?? self.amount
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
