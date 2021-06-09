//
//  DoRegistrationDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let doRegistrationDecodebleModel = try DoRegistrationDecodebleModel(json)

import Foundation

// MARK: - DoRegistrationDecodebleModel
struct DoRegistrationDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: JSONNull?
    let data: String?
}

// MARK: DoRegistrationDecodebleModel convenience initializers and mutators

extension DoRegistrationDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DoRegistrationDecodebleModel.self, from: data)
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
        errorMessage: JSONNull?? = nil,
        data: String?? = nil
    ) -> DoRegistrationDecodebleModel {
        return DoRegistrationDecodebleModel(
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

