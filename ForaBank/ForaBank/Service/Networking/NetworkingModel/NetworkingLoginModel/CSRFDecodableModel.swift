//
//  CSRFDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.06.2021.
//

import Foundation
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let cSRFDecodableModel = try CSRFDecodableModel(json)

import Foundation

// MARK: - CSRFDecodableModel
struct CSRFDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: JSONNull?
    let data: CSRFDataClass?
}

// MARK: CSRFDecodableModel convenience initializers and mutators

extension CSRFDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CSRFDecodableModel.self, from: data)
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
        errorMessage: JSONNull?? = nil,
        data: CSRFDataClass?? = nil
    ) -> CSRFDecodableModel {
        return CSRFDecodableModel(
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


// MARK: - DataClass
struct CSRFDataClass: Codable {
    let headerName, token, pk, sign: String?
    let cert: String?
}

// MARK: DataClass convenience initializers and mutators

extension CSRFDataClass {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CSRFDataClass.self, from: data)
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
        headerName: String?? = nil,
        token: String?? = nil,
        pk: String?? = nil,
        sign: String?? = nil,
        cert: String?? = nil
    ) -> CSRFDataClass {
        return CSRFDataClass(
            headerName: headerName ?? self.headerName,
            token: token ?? self.token,
            pk: pk ?? self.pk,
            sign: sign ?? self.sign,
            cert: cert ?? self.cert
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}



