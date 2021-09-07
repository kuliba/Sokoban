//
//  IsLoginDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.09.2021.
//

import Foundation

// MARK: - IsLoginDecodableModel
struct IsLoginDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: JSONNull?
}

// MARK: IsLoginDecodableModel convenience initializers and mutators

extension IsLoginDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(IsLoginDecodableModel.self, from: data)
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
        data: JSONNull?? = nil
    ) -> IsLoginDecodableModel {
        return IsLoginDecodableModel(
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
