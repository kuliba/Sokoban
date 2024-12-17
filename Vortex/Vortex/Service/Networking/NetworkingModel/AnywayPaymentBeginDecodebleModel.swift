//
//  AnywayPaymentBeginDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let anywayPaymentBeginDecodebleModel = try AnywayPaymentBeginDecodebleModel(json)

import Foundation

// MARK: - AnywayPaymentBeginDecodebleModel
struct AnywayPaymentBeginDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: Int?
}

// MARK: AnywayPaymentBeginDecodebleModel convenience initializers and mutators

extension AnywayPaymentBeginDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AnywayPaymentBeginDecodebleModel.self, from: data)
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
        data: Int?? = nil
    ) -> AnywayPaymentBeginDecodebleModel {
        return AnywayPaymentBeginDecodebleModel(
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
