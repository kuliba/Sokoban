//
//  KeyExchangeDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let keyExchangeDecodebleModel = try KeyExchangeDecodebleModel(json)

import Foundation

// MARK: - KeyExchangeDecodebleModel
struct KeyExchangeDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: KeyExchangeResultModel?
}

// MARK: KeyExchangeDecodebleModel convenience initializers and mutators

extension KeyExchangeDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(KeyExchangeDecodebleModel.self, from: data)
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
        data: KeyExchangeResultModel?? = nil
    ) -> KeyExchangeDecodebleModel {
        return KeyExchangeDecodebleModel(
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
    
    
    
//    {"data":"OK!?","type":null,"token":null}
}

// MARK: - CheckCardDataClass
struct KeyExchangeResultModel: Codable {
    let data: String?
    let type: String?
    let token: String?
}

// MARK: DataClass convenience initializers and mutators

extension KeyExchangeResultModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(KeyExchangeResultModel.self, from: data)
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
        data: String?? = nil,
        type: String?? = nil,
        token: String?? = nil
    ) -> KeyExchangeResultModel {
        return KeyExchangeResultModel(
            data: data ?? self.data,
            type: type ?? self.type,
            token: token ?? self.token
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
