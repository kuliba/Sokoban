//
//  FastPaymentBanksListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fastPaymentBanksListDecodableModel = try FastPaymentBanksListDecodableModel(json)

import Foundation

// MARK: - FastPaymentBanksListDecodableModel
struct FastPaymentBanksListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [FastPayment]?
}

// MARK: FastPaymentBanksListDecodableModel convenience initializers and mutators

extension FastPaymentBanksListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPaymentBanksListDecodableModel.self, from: data)
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
        data: [FastPayment]?? = nil
    ) -> FastPaymentBanksListDecodableModel {
        return FastPaymentBanksListDecodableModel(
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

// Datum.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let datum = try Datum(json)

// MARK: - Datum
struct FastPayment: Codable {
    let id, memberID, memberName, memberNameRus: String?
}

// MARK: Datum convenience initializers and mutators

extension FastPayment {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPayment.self, from: data)
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
        id: String?? = nil,
        memberID: String?? = nil,
        memberName: String?? = nil,
        memberNameRus: String?? = nil
    ) -> FastPayment {
        return FastPayment(
            id: id ?? self.id,
            memberID: memberID ?? self.memberID,
            memberName: memberName ?? self.memberName,
            memberNameRus: memberNameRus ?? self.memberNameRus
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
