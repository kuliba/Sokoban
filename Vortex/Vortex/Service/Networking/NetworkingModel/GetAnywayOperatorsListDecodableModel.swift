// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getAnywayOperatorsListDecodableModel = try GetAnywayOperatorsListDecodableModel(json)

import Foundation

// MARK: - GetAnywayOperatorsListDecodableModel
struct GetAnywayOperatorsListDecodableModel: Codable, NetworkModelProtocol {
    let data: GetAnywayOperatorsListDatum?
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
        data: GetAnywayOperatorsListDatum?? = nil,
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

// MARK: - DataClass
struct GetAnywayOperatorsListDatum: Codable {
    let operatorGroupList: [Operator]?
    let serial: String?
}

// MARK: DataClass convenience initializers and mutators

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
        operatorGroupList: [Operator]?? = nil,
        serial: String?? = nil
    ) -> GetAnywayOperatorsListDatum {
        return GetAnywayOperatorsListDatum(
            operatorGroupList: operatorGroupList ?? self.operatorGroupList,
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

// MARK: - Operator
struct Operator: Codable {
    let city, code: String?
    let isGroup: Bool?
    let logotypeList: [LogotypeList]?
    var name: String?
    let operators: [Operator]?
    let region: String?
    let synonymList: [String]?
    let parameterList: [ParameterList]?
    let parentCode: String?
}

// MARK: Operator convenience initializers and mutators

extension Operator {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Operator.self, from: data)
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
        operators: [Operator]?? = nil,
        region: String?? = nil,
        synonymList: [String]?? = nil,
        parameterList: [ParameterList]?? = nil,
        parentCode: String?? = nil
    ) -> Operator {
        return Operator(
            city: city ?? self.city,
            code: code ?? self.code,
            isGroup: isGroup ?? self.isGroup,
            logotypeList: logotypeList ?? self.logotypeList,
            name: name ?? self.name,
            operators: operators ?? self.operators,
            region: region ?? self.region,
            synonymList: synonymList ?? self.synonymList,
            parameterList: parameterList ?? self.parameterList,
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
    let content, contentType, name, svgImage: String?
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
        name: String?? = nil,
        svgImage: String?? = nil
    ) -> LogotypeList {
        return LogotypeList(
            content: content ?? self.content,
            contentType: contentType ?? self.contentType,
            name: name ?? self.name,
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

// MARK: - ParameterList
struct ParameterList: Codable {
    let content, dataType, id: String?
    let svgImage: String?
    let isRequired: Bool?
    let mask: String?
    let maxLength, minLength, order, rawLength: Int?
    let readOnly: Bool?
    let regExp, subTitle, title, type: String?
    let viewType: String?
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

//    func with(
//        content: String?? = nil,
//        dataType: String?? = nil,
//        id: String?? = nil,
//        isRequired: Bool?? = nil,
//        mask: String?? = nil,
//        maxLength: Int?? = nil,
//        minLength: Int?? = nil,
//        order: Int?? = nil,
//        rawLength: Int?? = nil,
//        readOnly: Bool?? = nil,
//        regExp: String?? = nil,
//        subTitle: String?? = nil,
//        title: String?? = nil,
//        type: String?? = nil,
//        viewType: String?? = nil
//    ) -> ParameterList {
//        return ParameterList(
//            content: content ?? self.content,
//            dataType: dataType ?? self.dataType,
//            id: id ?? self.id,
//            isRequired: isRequired ?? self.isRequired,
//            mask: mask ?? self.mask,
//            maxLength: maxLength ?? self.maxLength,
//            minLength: minLength ?? self.minLength,
//            order: order ?? self.order,
//            rawLength: rawLength ?? self.rawLength,
//            readOnly: readOnly ?? self.readOnly,
//            regExp: regExp ?? self.regExp,
//            subTitle: subTitle ?? self.subTitle,
//            title: title ?? self.title,
//            type: type ?? self.type,
//            viewType: viewType ?? self.viewType
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
