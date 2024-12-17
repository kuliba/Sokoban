//
//  GetSessionTimeoutDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.09.2021.
//

import Foundation

// MARK: - GetSessionTimeoutDecodableModel
struct GetSessionTimeoutDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: Int?
}

// MARK: GetSessionTimeoutDecodableModel convenience initializers and mutators

extension GetSessionTimeoutDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetSessionTimeoutDecodableModel.self, from: data)
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
    ) -> GetSessionTimeoutDecodableModel {
        return GetSessionTimeoutDecodableModel(
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
