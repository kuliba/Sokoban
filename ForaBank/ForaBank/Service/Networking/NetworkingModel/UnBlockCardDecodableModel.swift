//
//  UnBlockCardDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation

// MARK: - UnBlockCardDecodableModel
struct UnBlockCardDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: UnBlockCardDataClass?
}

// MARK: UnBlockCardDecodableModel convenience initializers and mutators

extension UnBlockCardDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UnBlockCardDecodableModel.self, from: data)
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
        data: UnBlockCardDataClass?? = nil
    ) -> UnBlockCardDecodableModel {
        return UnBlockCardDecodableModel(
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

// MARK: - UnBlockCardDataClass
struct UnBlockCardDataClass: Codable {
    let cardID: Int?
    let cardNumber: String?
}

// MARK: UnBlockCardDataClass convenience initializers and mutators

extension UnBlockCardDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(UnBlockCardDataClass.self, from: data)
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
    ) -> UnBlockCardDataClass {
        return UnBlockCardDataClass(
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
