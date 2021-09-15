//
//  BlockCardDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation

// MARK: - BlockCardDecodableModel
struct BlockCardDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: BlockCardDataClass?
}

// MARK: BlockCardDecodableModel convenience initializers and mutators

extension BlockCardDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BlockCardDecodableModel.self, from: data)
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
        data: BlockCardDataClass?? = nil
    ) -> BlockCardDecodableModel {
        return BlockCardDecodableModel(
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

// MARK: - BlockCardDataClass
struct BlockCardDataClass: Codable {
    let cardID: Int?
    let cardNumber: String?
}

// MARK: DataClass convenience initializers and mutators

extension BlockCardDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BlockCardDataClass.self, from: data)
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
        cardID: Int?? = nil,
        cardNumber: String?? = nil
    ) -> BlockCardDataClass {
        return BlockCardDataClass(
            cardID: cardID ?? self.cardID,
            cardNumber: cardNumber ?? self.cardNumber
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
