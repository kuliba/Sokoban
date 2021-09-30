//
//  GetAccountStatementDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.09.2021.
//

import Foundation

// MARK: - GetAccountStatementDecodableModel
struct GetAccountStatementDecodableModel: Codable, NetworkModelProtocol {
    let data: [GetAccountStatementDatum]?
    let errorMessage: String?
    let statusCode: Int?
}

// MARK: GetAccountStatementDecodableModel convenience initializers and mutators

extension GetAccountStatementDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAccountStatementDecodableModel.self, from: data)
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
        data: [GetAccountStatementDatum]?? = nil,
        errorMessage: String?? = nil,
        statusCode: Int?? = nil
    ) -> GetAccountStatementDecodableModel {
        return GetAccountStatementDecodableModel(
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

// MARK: - GetAccountStatementDatum
struct GetAccountStatementDatum: Codable {
    let accountID: Int?
    let accountNumber: String?
    let amount: Int?
    let comment: String?
    let currencyCodeNumeric: Int?
    let date: String?
    let documentID: Int?
    let name, operationType, tranDate: String?
}

// MARK: GetAccountStatementDatum convenience initializers and mutators

extension GetAccountStatementDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAccountStatementDatum.self, from: data)
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
        accountNumber: String?? = nil,
        amount: Int?? = nil,
        comment: String?? = nil,
        currencyCodeNumeric: Int?? = nil,
        date: String?? = nil,
        documentID: Int?? = nil,
        name: String?? = nil,
        operationType: String?? = nil,
        tranDate: String?? = nil
    ) -> Datum {
        return Datum(
            accountID: accountID ?? self.accountID,
            accountNumber: accountNumber ?? self.accountNumber,
            amount: amount ?? self.amount,
            comment: comment ?? self.comment,
            currencyCodeNumeric: currencyCodeNumeric ?? self.currencyCodeNumeric,
            date: date ?? self.date,
            documentID: documentID ?? self.documentID,
            name: name ?? self.name,
            operationType: operationType ?? self.operationType,
            tranDate: tranDate ?? self.tranDate
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
