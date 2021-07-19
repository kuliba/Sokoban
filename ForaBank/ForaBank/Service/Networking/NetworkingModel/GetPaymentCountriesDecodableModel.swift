//
//  GetPaymentCountriesDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.07.2021.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getPaymentCountriesDecodableModel = try GetPaymentCountriesDecodableModel(json)

import Foundation

// MARK: - GetPaymentCountriesDecodableModel
struct GetPaymentCountriesDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetPaymentCountriesDatum]?
}

// MARK: GetPaymentCountriesDecodableModel convenience initializers and mutators

extension GetPaymentCountriesDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetPaymentCountriesDecodableModel.self, from: data)
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
        data: [GetPaymentCountriesDatum]?? = nil
    ) -> GetPaymentCountriesDecodableModel {
        return GetPaymentCountriesDecodableModel(
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

// MARK: - GetPaymentCountriesDatum
struct GetPaymentCountriesDatum: Codable {
    let surName, firstName, middleName, shortName: String?
    let countryName, countryCode, puref, phoneNumber: String?
}

// MARK: GetPaymentCountriesDatum convenience initializers and mutators

extension GetPaymentCountriesDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetPaymentCountriesDatum.self, from: data)
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
        surName: String?? = nil,
        firstName: String?? = nil,
        middleName: String?? = nil,
        shortName: String?? = nil,
        countryName: String?? = nil,
        countryCode: String?? = nil,
        puref: String?? = nil,
        phoneNumber: String?? = nil
    ) -> GetPaymentCountriesDatum {
        return GetPaymentCountriesDatum(
            surName: surName ?? self.surName,
            firstName: firstName ?? self.firstName,
            middleName: middleName ?? self.middleName,
            shortName: shortName ?? self.shortName,
            countryName: countryName ?? self.countryName,
            countryCode: countryCode ?? self.countryCode,
            puref: puref ?? self.puref,
            phoneNumber: phoneNumber ?? self.phoneNumber
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
