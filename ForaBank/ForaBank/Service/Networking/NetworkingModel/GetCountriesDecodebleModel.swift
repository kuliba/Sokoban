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
    let data: GetCountriesDataClass?
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
        data: GetCountriesDataClass?? = nil
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

// DataClass.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let dataClass = try DataClass(json)

// MARK: - GetCountriesDataClass
struct GetCountriesDataClass: Codable {
    let countriesList: [CountriesList]?
    let serial: String?
}

// MARK: DataClass convenience initializers and mutators

extension GetCountriesDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetCountriesDataClass.self, from: data)
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
        countriesList: [CountriesList]?? = nil,
        serial: String?? = nil
    ) -> GetCountriesDataClass {
        return GetCountriesDataClass(
            countriesList: countriesList ?? self.countriesList,
            serial: serial ?? self.serial
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// CountriesList.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let countriesList = try CountriesList(json)
// MARK: - CountriesList
struct CountriesList: Codable {
    let code, contactCode, name: String?
    let sendCurr: SendCurr?
    let md5Hash, svgImage: String?
    let paymentSystemCodeList: [String]?

    enum CodingKeys: String, CodingKey {
        case code, name, sendCurr, contactCode
        case md5Hash = "md5hash"
        case svgImage
        case paymentSystemCodeList = "paymentSystemIdList"
    }
}

// MARK: CountriesList convenience initializers and mutators

extension CountriesList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CountriesList.self, from: data)
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
        contactCode: String?? = nil,
        name: String?? = nil,
        sendCurr: SendCurr?? = nil,
        md5Hash: String?? = nil,
        svgImage: String?? = nil,
        paymentSystemCodeList: [String]?? = nil
    ) -> CountriesList {
        return CountriesList(
            code: code ?? self.code,
            contactCode: contactCode ?? self.contactCode,
            name: name ?? self.name,
            sendCurr: sendCurr ?? self.sendCurr,
            md5Hash: md5Hash ?? self.md5Hash,
            svgImage: svgImage ?? self.svgImage,
            paymentSystemCodeList: paymentSystemCodeList ?? self.paymentSystemCodeList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// PaymentSystemIDList.swift

//import Foundation
//
//enum PaymentSystemIDList: String, Codable, CaseIterable {
//    case contact = "CONTACT"
//    case direct = "DIRECT"
//}

// SendCurr.swift

import Foundation

enum SendCurr: String, Codable {
    case empty = ""
    case eur = "EUR;"
    case rurUsdEur = "RUR;USD;EUR;"
    case usd = "USD;"
    case usdEur = "USD;EUR;"
}

