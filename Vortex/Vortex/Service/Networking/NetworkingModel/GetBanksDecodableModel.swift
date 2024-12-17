//
//  GetBanksDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.06.2021.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getBanksDecodableModel = try GetBanksDecodableModel(json)

import Foundation

// MARK: - GetBanksDecodableModel
struct GetBanksDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetBanksDataClass?
}

// MARK: GetBanksDecodableModel convenience initializers and mutators

extension GetBanksDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetBanksDecodableModel.self, from: data)
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
        data: GetBanksDataClass?? = nil
    ) -> GetBanksDecodableModel {
        return GetBanksDecodableModel(
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

// MARK: - GetBanksDataClass
struct GetBanksDataClass: Codable {
    let banksList: [BanksList]?
    let serial: String?
}

// MARK: DataClass convenience initializers and mutators

extension GetBanksDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetBanksDataClass.self, from: data)
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
        banksList: [BanksList]?? = nil,
        serial: String?? = nil
    ) -> GetBanksDataClass {
        return GetBanksDataClass(
            banksList: banksList ?? self.banksList,
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

// BanksList.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let banksList = try BanksList(json)

// MARK: - BanksList
struct BanksList: Codable {
    var memberID, memberName, memberNameRus: String?
    let md5Hash, svgImage: String?
    let paymentSystemCodeList: [String]?

    enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case memberName, memberNameRus
        case md5Hash = "md5hash"
        case svgImage, paymentSystemCodeList
    }
}

// MARK: BanksList convenience initializers and mutators

extension BanksList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BanksList.self, from: data)
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
        memberID: String?? = nil,
        memberName: String?? = nil,
        memberNameRus: String?? = nil,
        md5Hash: String?? = nil,
        svgImage: String?? = nil,
        paymentSystemCodeList: [String]?? = nil
    ) -> BanksList {
        return BanksList(
            memberID: memberID ?? self.memberID,
            memberName: memberName ?? self.memberName,
            memberNameRus: memberNameRus ?? self.memberNameRus,
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

// PaymentSystemCodeList.swift

enum PaymentSystemCodeList: String, Codable, CaseIterable {
    case direct = "DIRECT"
    case sfp = "SFP"
}
