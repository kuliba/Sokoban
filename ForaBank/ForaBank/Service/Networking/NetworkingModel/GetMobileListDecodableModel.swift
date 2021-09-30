//
//  GetMobileListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.09.2021.
//

import Foundation

// MARK: - GetMobileListDecodableModel
struct GetMobileListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetMobileListDataClass?
}

// MARK: GetMobileListDecodableModel convenience initializers and mutators

extension GetMobileListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetMobileListDecodableModel.self, from: data)
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
        data: GetMobileListDataClass?? = nil
    ) -> GetMobileListDecodableModel {
        return GetMobileListDecodableModel(
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


// MARK: - GetMobileListDataClass
struct GetMobileListDataClass: Codable {
    let serial: String?
    let mobileList: [MobileList]?
}

// MARK: DataClass convenience initializers and mutators

extension GetMobileListDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetMobileListDataClass.self, from: data)
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
        mobileList: [MobileList]?? = nil
    ) -> GetMobileListDataClass {
        return GetMobileListDataClass(
            serial: serial ?? self.serial,
            mobileList: mobileList ?? self.mobileList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


// MARK: - MobileList
struct MobileList: Codable {
    let code, providerName, puref, md5Hash: String?
    let svgImage: String?

    enum CodingKeys: String, CodingKey {
        case code, providerName, puref
        case md5Hash = "md5hash"
        case svgImage
    }
}

// MARK: MobileList convenience initializers and mutators

extension MobileList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(MobileList.self, from: data)
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
        providerName: String?? = nil,
        puref: String?? = nil,
        md5Hash: String?? = nil,
        svgImage: String?? = nil
    ) -> MobileList {
        return MobileList(
            code: code ?? self.code,
            providerName: providerName ?? self.providerName,
            puref: puref ?? self.puref,
            md5Hash: md5Hash ?? self.md5Hash,
            svgImage: svgImage ?? self.svgImage
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
