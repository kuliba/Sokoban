//
//  CreatTransferDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let creatTransferDecodableModel = try CreatTransferDecodableModel(json)

import Foundation

// MARK: - CreatTransferDecodableModel
struct CreatTransferDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: CreatTransferDataClass?
}

// MARK: CreatTransferDecodableModel convenience initializers and mutators

extension CreatTransferDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreatTransferDecodableModel.self, from: data)
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
        data: CreatTransferDataClass?? = nil
    ) -> CreatTransferDecodableModel {
        return CreatTransferDecodableModel(
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

// MARK: - CreatTransferDataClass
struct CreatTransferDataClass: Codable {
    let fee: Double?
    let needMake: Bool?
}

// MARK: DataClass convenience initializers and mutators

extension CreatTransferDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CreatTransferDataClass.self, from: data)
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
        fee: Double?? = nil,
        needMake: Bool?? = nil
    ) -> CreatTransferDataClass {
        return CreatTransferDataClass(
            fee: fee ?? self.fee,
            needMake: needMake ?? self.needMake
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
