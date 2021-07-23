//
//  GetAnywayOperatorsListDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 22.07.2021.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getAnywayOperatorsListDecodableModel = try GetAnywayOperatorsListDecodableModel(json)

import Foundation

// MARK: - GetAnywayOperatorsListDecodableModel
struct GetAnywayOperatorsListDecodableModel: Codable, NetworkModelProtocol {
    let data: [GetAnywayOperatorsListDatum]?
    let errorMessage: String?
    let statusCode: Int?
}

// MARK: GetAnywayOperatorsListDecodableModel convenience initializers and mutators

extension GetAnywayOperatorsListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAnywayOperatorsListDecodableModel.self, from: data)
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
        data: [GetAnywayOperatorsListDatum]?? = nil,
        errorMessage: String?? = nil,
        statusCode: Int?? = nil
    ) -> GetAnywayOperatorsListDecodableModel {
        return GetAnywayOperatorsListDecodableModel(
            data: data ?? self.data,
            errorMessage: errorMessage ?? self.errorMessage,
            statusCode: statusCode ?? self.statusCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


// MARK: - GetAnywayOperatorsListDatum
struct GetAnywayOperatorsListDatum: Codable {
    let city, code: String?
    let isGroup: Bool?
    let logotypeList: [LogotypeList]?
    let name: String?
    let operators: [GetAnywayOperatorsListDatum]?
    let region: String?
    let synonymList: [String]?
    let parentCode: String?
}

// MARK: GetAnywayOperatorsListDatum convenience initializers and mutators

extension GetAnywayOperatorsListDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAnywayOperatorsListDatum.self, from: data)
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
        city: String?? = nil,
        code: String?? = nil,
        isGroup: Bool?? = nil,
        logotypeList: [LogotypeList]?? = nil,
        name: String?? = nil,
        operators: [GetAnywayOperatorsListDatum]?? = nil,
        region: String?? = nil,
        synonymList: [String]?? = nil,
        parentCode: String?? = nil
    ) -> GetAnywayOperatorsListDatum {
        return GetAnywayOperatorsListDatum(
            city: city ?? self.city,
            code: code ?? self.code,
            isGroup: isGroup ?? self.isGroup,
            logotypeList: logotypeList ?? self.logotypeList,
            name: name ?? self.name,
            operators: operators ?? self.operators,
            region: region ?? self.region,
            synonymList: synonymList ?? self.synonymList,
            parentCode: parentCode ?? self.parentCode
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - LogotypeList
struct LogotypeList: Codable {
    let content, contentType, name: String?
}

// MARK: LogotypeList convenience initializers and mutators

extension LogotypeList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LogotypeList.self, from: data)
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
        content: String?? = nil,
        contentType: String?? = nil,
        name: String?? = nil
    ) -> LogotypeList {
        return LogotypeList(
            content: content ?? self.content,
            contentType: contentType ?? self.contentType,
            name: name ?? self.name
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
