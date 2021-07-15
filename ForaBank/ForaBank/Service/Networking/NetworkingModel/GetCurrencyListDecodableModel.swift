//
//  GetCurrencyListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.07.2021.
//

import Foundation

// MARK: - GetCurrencyListDecodableModel
struct GetCurrencyListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetCurrencyListDataClass?
}

// MARK: GetCurrencyListDecodableModel convenience initializers and mutators

extension GetCurrencyListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCurrencyListDecodableModel.self, from: data)
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
        data: GetCurrencyListDataClass?? = nil
    ) -> GetCurrencyListDecodableModel {
        return GetCurrencyListDecodableModel(
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

// MARK: - GetCurrencyListDataClass
struct GetCurrencyListDataClass: Codable {
    let serial: String?
    let currencyList: [CurrencyList]?
}

// MARK: GetCurrencyListDataClass convenience initializers and mutators

extension GetCurrencyListDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCurrencyListDataClass.self, from: data)
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
        serial: String?? = nil,
        currencyList: [CurrencyList]?? = nil
    ) -> GetCurrencyListDataClass {
        return GetCurrencyListDataClass(
            serial: serial ?? self.serial,
            currencyList: currencyList ?? self.currencyList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - CurrencyList
struct CurrencyList: Codable {
    let id, code, name, unicode: String?
    let htmlCode, cssCode: String?
}
