//
//  GetPaymentSystemListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getPaymentSystemListDecodableModel = try GetPaymentSystemListDecodableModel(json)

import Foundation

// MARK: - GetPaymentSystemListDecodableModel
struct GetPaymentSystemListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetPaymentSystemListDataClass?
}

// MARK: GetPaymentSystemListDecodableModel convenience initializers and mutators

extension GetPaymentSystemListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetPaymentSystemListDecodableModel.self, from: data)
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
        data: GetPaymentSystemListDataClass?? = nil
    ) -> GetPaymentSystemListDecodableModel {
        return GetPaymentSystemListDecodableModel(
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

// MARK: - GetPaymentSystemListDataClass
struct GetPaymentSystemListDataClass: Codable {
    let paymentSystemList: [PaymentSystemList]?
    let serial: String?
}

// MARK: DataClass convenience initializers and mutators

extension GetPaymentSystemListDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetPaymentSystemListDataClass.self, from: data)
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
        paymentSystemList: [PaymentSystemList]?? = nil,
        serial: String?? = nil
    ) -> GetPaymentSystemListDataClass {
        return GetPaymentSystemListDataClass(
            paymentSystemList: paymentSystemList ?? self.paymentSystemList,
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

// MARK: - PaymentSystemList
struct PaymentSystemList: Codable {
    let code, name, md5Hash, svgImage: String?
    let purefList: [[String: [PurefList]]]?

    enum CodingKeys: String, CodingKey {
        case code, name
        case md5Hash = "md5hash"
        case svgImage, purefList
    }
}

// MARK: PaymentSystemList convenience initializers and mutators

extension PaymentSystemList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PaymentSystemList.self, from: data)
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
        md5Hash: String?? = nil,
        svgImage: String?? = nil,
        purefList: [[String: [PurefList]]]?? = nil
    ) -> PaymentSystemList {
        return PaymentSystemList(
            code: code ?? self.code,
            name: name ?? self.name,
            md5Hash: md5Hash ?? self.md5Hash,
            svgImage: svgImage ?? self.svgImage,
            purefList: purefList ?? self.purefList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - PurefList
struct PurefList: Codable {
    let puref: String?
    let type: String?
}

// MARK: PurefList convenience initializers and mutators

extension PurefList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PurefList.self, from: data)
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
        puref: String?? = nil,
        type: String?? = nil
    ) -> PurefList {
        return PurefList(
            puref: puref ?? self.puref,
            type: type ?? self.type
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// TypeEnum.swift

//enum TypeEnum: String, Codable {
//    case account = "account"
//    case addressing = "addressing"
//    case addressless = "addressless"
//    case card = "card"
//    case phone = "phone"
//}
