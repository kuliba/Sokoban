//
//  SaveCardNameDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation

// MARK: - SaveCardNameDecodableModel
struct SaveCardNameDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: SaveCardNameDataClass?
}

// MARK: SaveCardNameDecodableModel convenience initializers and mutators

extension SaveCardNameDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SaveCardNameDecodableModel.self, from: data)
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
        data: SaveCardNameDataClass?? = nil
    ) -> SaveCardNameDecodableModel {
        return SaveCardNameDecodableModel(
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

// MARK: - SaveCardNameDataClass
struct SaveCardNameDataClass: Codable {
    let cardNumber, endDate: String?
    let id: Int?
    let name, startDate, statementFormat: String?
}

// MARK: SaveCardNameDataClass convenience initializers and mutators

extension SaveCardNameDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SaveCardNameDataClass.self, from: data)
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
        cardNumber: String?? = nil,
        endDate: String?? = nil,
        id: Int?? = nil,
        name: String?? = nil,
        startDate: String?? = nil,
        statementFormat: String?? = nil
    ) -> SaveCardNameDataClass {
        return SaveCardNameDataClass(
            cardNumber: cardNumber ?? self.cardNumber,
            endDate: endDate ?? self.endDate,
            id: id ?? self.id,
            name: name ?? self.name,
            startDate: startDate ?? self.startDate,
            statementFormat: statementFormat ?? self.statementFormat
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
