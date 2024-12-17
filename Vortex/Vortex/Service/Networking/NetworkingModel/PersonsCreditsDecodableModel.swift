//
//  PersonsCreditsDecodableModel.swift
//  ForaBank
//
//  Created by Дмитрий on 25.03.2022.
//

import Foundation

// MARK: - AnywayPaymentDecodableModel
struct PersonsCreditsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: PersonsCreditItemModel?
}

// MARK: PersonsCreditsDecodableModel convenience initializers and mutators

extension PersonsCreditsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PersonsCreditsDecodableModel.self, from: data)
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
        data: PersonsCreditItemModel?? = nil
    ) -> PersonsCreditsDecodableModel {
        return PersonsCreditsDecodableModel(
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
struct PersonsCreditItemModel: Codable, Equatable {
    
    let original: PersonsCreditDataModel?
    let customName: String?
}

extension PersonsCreditItemModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PersonsCreditItemModel.self, from: data)
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
        original: PersonsCreditDataModel?? = nil,
        customName: String?? = nil
    ) -> PersonsCreditItemModel {
        return PersonsCreditItemModel(
            original: original ?? self.original,
            customName: customName ?? self.customName
            
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

import Foundation

struct PersonsCreditDataModel: Codable, Equatable {
    
    let loanId: Int?
    let clientId: Int
    let currencyCode: String?
    let currencyNumber: Int?
    let currencyId: Int?
    let number: String?
    let datePayment: Int?
    let amountCredit: Double?
    let amountRepaid: Double?
    let amountPayment: Double?
    let overduePayment: Double?
    
    enum CodingKeys: String, CodingKey {
        case loanId = "loandID"
        case clientId = "clientID"
        case currencyId = "currencyId"
        case currencyCode, currencyNumber, number, datePayment, amountCredit, amountRepaid, amountPayment, overduePayment
    }
}

extension PersonsCreditDataModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PersonsCreditDataModel.self, from: data)
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
        loanId: Int?? = nil,
        clientId: Int,
        currencyCode: String?? = nil,
        currencyNumber: Int?? = nil,
        currencyId: Int?? = nil,
        number: String?? = nil,
        datePayment: Int?? = nil,
        amountCredit: Double?? = nil,
        amountRepaid: Double?? = nil,
        amountPayment: Double?? = nil,
        overduePayment: Double?? = nil
    ) -> PersonsCreditDataModel {
        return PersonsCreditDataModel(
            loanId: loanId ?? self.loanId,
            clientId: clientId,
            currencyCode: currencyCode ?? self.currencyCode,
            currencyNumber: currencyNumber ?? self.currencyNumber,
            currencyId: currencyId ?? self.currencyId,
            number: number ?? self.number,
            datePayment: datePayment ?? self.datePayment,
            amountCredit: amountCredit ?? self.amountCredit,
            amountRepaid: amountRepaid ?? self.amountRepaid,
            amountPayment: amountPayment ?? self.amountPayment,
            overduePayment: overduePayment ?? self.overduePayment
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
