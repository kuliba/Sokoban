// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getAnywayOperatorsListDecodableModel = try GetAnywayOperatorsListDecodableModel(json)

import Foundation

// MARK: - GetAnywayOperatorsListDecodableModel
struct GetAnywayOperatorsListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetAnywayOperatorsListDatum]?
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
        statusCode: Int?? = nil,
        errorMessage: String?? = nil,
        data: [GetAnywayOperatorsListDatum]?? = nil
    ) -> GetAnywayOperatorsListDecodableModel {
        return GetAnywayOperatorsListDecodableModel(
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

// MARK: - GetAnywayOperatorsListDatum
struct GetAnywayOperatorsListDatum: Codable {
    let code, name: String?
    let region: String?
    let city: JSONNull?
    let isGroup: Bool?
    let synonymList: [String]?
    let logotypeList: [LogotypeList]?
    let operators: [GetAnywayOperatorsListDatum]?
    let parentCode: String?
    let parameterList: [ParameterList]?
}

// MARK: Datum convenience initializers and mutators

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
        code: String?? = nil,
        name: String?? = nil,
        region: String?? = nil,
        city: JSONNull?? = nil,
        isGroup: Bool?? = nil,
        synonymList: [String]?? = nil,
        logotypeList: [LogotypeList]?? = nil,
        operators: [GetAnywayOperatorsListDatum]?? = nil,
        parentCode: String?? = nil,
        parameterList: [ParameterList]?? = nil
    ) -> GetAnywayOperatorsListDatum {
        return GetAnywayOperatorsListDatum (
            code: code ?? self.code,
            name: name ?? self.name,
            region: region ?? self.region,
            city: city ?? self.city,
            isGroup: isGroup ?? self.isGroup,
            synonymList: synonymList ?? self.synonymList,
            logotypeList: logotypeList ?? self.logotypeList,
            operators: operators ?? self.operators,
            parentCode: parentCode ?? self.parentCode,
            parameterList: parameterList ?? self.parameterList
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
    let name: String?
    let contentType: JSONNull?
    let content: String?
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
        name: String?? = nil,
        contentType: JSONNull?? = nil,
        content: String?? = nil
    ) -> LogotypeList {
        return LogotypeList(
            name: name ?? self.name,
            contentType: contentType ?? self.contentType,
            content: content ?? self.content
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ParameterList
struct ParameterList: Codable {
    let id: String?
    let order: Int?
    let title: String?
    let subTitle: String?
    let viewType: ViewType?
    let dataType: DataType?
    let type: TypeEnums?
    let mask, regExp: String?
    let maxLength, minLength: Int?
    let rawLength: Int?
    let isRequired: Bool?
}

// MARK: ParameterList convenience initializers and mutators

extension ParameterList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ParameterList.self, from: data)
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
        id: String?? = nil,
        order: Int?? = nil,
        title: String?? = nil,
        subTitle: String?? = nil,
        viewType: ViewType?? = nil,
        dataType: DataType?? = nil,
        type: TypeEnums?? = nil,
        mask: String?? = nil,
        regExp: String?? = nil,
        maxLength: Int?? = nil,
        minLength: Int?? = nil,
        rawLength: Int?? = nil,
        isRequired: Bool?? = nil
    ) -> ParameterList {
        return ParameterList(
            id: id ?? self.id,
            order: order ?? self.order,
            title: title ?? self.title,
            subTitle: subTitle ?? self.subTitle,
            viewType: viewType ?? self.viewType,
            dataType: dataType ?? self.dataType,
            type: type ?? self.type,
            mask: mask ?? self.mask,
            regExp: regExp ?? self.regExp,
            maxLength: maxLength ?? self.maxLength,
            minLength: minLength ?? self.minLength,
            rawLength: rawLength ?? self.rawLength,
            isRequired: isRequired ?? self.isRequired
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum DataType: String, Codable {
    case number = "%Number"
    case numeric = "%Numeric"
    case string = "%String"
}

enum TypeEnums: String, Codable {
    case int = "Int"
    case maskList = "MaskList"
    case string = "String"
}

// ViewType.swift

import Foundation

enum ViewType: String, Codable {
    case input = "INPUT"
    case output = "OUTPUT"
}
