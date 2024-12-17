//
//  DeleteProductTemplateDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.07.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let deleteProductTemplateDecodableModel = try DeleteProductTemplateDecodableModel(json)

import Foundation

// MARK: - DeleteProductTemplateDecodableModel
struct DeleteProductTemplateDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: JSONNull?
}

// MARK: DeleteProductTemplateDecodableModel convenience initializers and mutators

extension DeleteProductTemplateDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DeleteProductTemplateDecodableModel.self, from: data)
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
    ) -> DeleteProductTemplateDecodableModel {
        return DeleteProductTemplateDecodableModel(
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
