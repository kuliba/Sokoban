//
//  GetCountriesDecodebleModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 11.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getCountriesDecodebleModel = try GetCountriesDecodebleModel(json)

import Foundation

// MARK: - GetCountriesDecodebleModel
struct GetCountriesDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetCountryDatum]?
}

// MARK: GetCountriesDecodebleModel convenience initializers and mutators

extension GetCountriesDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCountriesDecodebleModel.self, from: data)
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
        data: [GetCountryDatum]?? = nil
    ) -> GetCountriesDecodebleModel {
        return GetCountriesDecodebleModel(
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

// Datum.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let datum = try Datum(json)

// MARK: - GetCountryDatum
struct GetCountryDatum: Codable {
    let code, name: String?
    let sendCurr: SendCurr?
}

// MARK: Datum convenience initializers and mutators

extension GetCountryDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCountryDatum.self, from: data)
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
        code: String?? = nil,
        name: String?? = nil,
        sendCurr: SendCurr?? = nil
    ) -> GetCountryDatum {
        return GetCountryDatum(
            code: code ?? self.code,
            name: name ?? self.name,
            sendCurr: sendCurr ?? self.sendCurr
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// SendCurr.swift

enum SendCurr: String, Codable {
    case empty = ""
    case eur = "EUR;"
    case rurUsdEur = "RUR;USD;EUR;"
    case usd = "USD;"
    case usdEur = "USD;EUR;"
}

