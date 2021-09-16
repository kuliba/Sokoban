//
//  GetProductDetailsDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.09.2021.
//

import Foundation

// MARK: - GetProductDetailsDecodableModel
struct GetProductDetailsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetProductDetailsDataClass?
}

// MARK: GetProductDetailsDecodableModel convenience initializers and mutators

extension GetProductDetailsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetProductDetailsDecodableModel.self, from: data)
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
        data: GetProductDetailsDataClass?? = nil
    ) -> GetProductDetailsDecodableModel {
        return GetProductDetailsDecodableModel(
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

// MARK: - GetProductDetailsDataClass
struct GetProductDetailsDataClass: Codable {
    let payeeName, cardNumber, accountNumber, bic: String?
    let corrAccount, inn, kpp: String?
}

// MARK: DataClass convenience initializers and mutators

extension GetProductDetailsDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetProductDetailsDataClass.self, from: data)
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
        payeeName: String?? = nil,
        cardNumber: String?? = nil,
        accountNumber: String?? = nil,
        bic: String?? = nil,
        corrAccount: String?? = nil,
        inn: String?? = nil,
        kpp: String?? = nil
    ) -> GetProductDetailsDataClass {
        return GetProductDetailsDataClass(
            payeeName: payeeName ?? self.payeeName,
            cardNumber: cardNumber ?? self.cardNumber,
            accountNumber: accountNumber ?? self.accountNumber,
            bic: bic ?? self.bic,
            corrAccount: corrAccount ?? self.corrAccount,
            inn: inn ?? self.inn,
            kpp: kpp ?? self.kpp
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
