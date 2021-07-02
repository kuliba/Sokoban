//
//  GetExchangeCurrencyRatesDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.07.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getExchangeCurrencyRatesDecodableModel = try GetExchangeCurrencyRatesDecodableModel(json)

import Foundation

// MARK: - GetExchangeCurrencyRatesDecodableModel
struct GetExchangeCurrencyRatesDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetExchangeCurrencyDataClass?
}

// MARK: GetExchangeCurrencyRatesDecodableModel convenience initializers and mutators

extension GetExchangeCurrencyRatesDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetExchangeCurrencyRatesDecodableModel.self, from: data)
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
        data: GetExchangeCurrencyDataClass?? = nil
    ) -> GetExchangeCurrencyRatesDecodableModel {
        return GetExchangeCurrencyRatesDecodableModel(
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

// MARK: - GetExchangeCurrencyDataClass
struct GetExchangeCurrencyDataClass: Codable {
    let currencyID: Int?
    let currencyCodeAlpha, currencyCodeNumeric, currencyName: String?
    let rateBuy: Double?
    let rateBuyDate: Int?
    let rateSell: Double?
    let rateSellDate, rateTypeID: Int?
    let rateType: String?
}

// MARK: DataClass convenience initializers and mutators

extension GetExchangeCurrencyDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetExchangeCurrencyDataClass.self, from: data)
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
        currencyID: Int?? = nil,
        currencyCodeAlpha: String?? = nil,
        currencyCodeNumeric: String?? = nil,
        currencyName: String?? = nil,
        rateBuy: Double?? = nil,
        rateBuyDate: Int?? = nil,
        rateSell: Double?? = nil,
        rateSellDate: Int?? = nil,
        rateTypeID: Int?? = nil,
        rateType: String?? = nil
    ) -> GetExchangeCurrencyDataClass {
        return GetExchangeCurrencyDataClass(
            currencyID: currencyID ?? self.currencyID,
            currencyCodeAlpha: currencyCodeAlpha ?? self.currencyCodeAlpha,
            currencyCodeNumeric: currencyCodeNumeric ?? self.currencyCodeNumeric,
            currencyName: currencyName ?? self.currencyName,
            rateBuy: rateBuy ?? self.rateBuy,
            rateBuyDate: rateBuyDate ?? self.rateBuyDate,
            rateSell: rateSell ?? self.rateSell,
            rateSellDate: rateSellDate ?? self.rateSellDate,
            rateTypeID: rateTypeID ?? self.rateTypeID,
            rateType: rateType ?? self.rateType
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
