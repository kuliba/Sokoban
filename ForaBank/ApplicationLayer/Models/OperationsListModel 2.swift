// OperationsList.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let operationsList = try OperationsList(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.operationsListTask(with: url) { operationsList, response, error in
//     if let operationsList = operationsList {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseOperationsList { response in
//     if let operationsList = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - OperationsList
struct OperationsList: Codable {
    var data: [Datum]?
    var errorMessage, result: String?
}

// MARK: OperationsList convenience initializers and mutators

extension OperationsList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(OperationsList.self, from: data)
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
        data: [Datum]?? = nil,
        errorMessage: String?? = nil,
        result: String?? = nil
    ) -> OperationsList {
        return OperationsList(
            data: data ?? self.data,
            errorMessage: errorMessage ?? self.errorMessage,
            result: result ?? self.result
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Datum.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let datum = try Datum(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.datumTask(with: url) { datum, response, error in
//     if let datum = datum {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDatum { response in
//     if let datum = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Datum
struct Datum: Codable {
    var details: OperationsDetails?
    var logo, name: String?
    var operators: [OperationsDetails]?
}

// MARK: Datum convenience initializers and mutators

extension Datum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Datum.self, from: data)
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
        details: OperationsDetails?? = nil,
        logo: String?? = nil,
        name: String?? = nil,
        operators: [OperationsDetails]?? = nil
    ) -> Datum {
        return Datum(
            details: details ?? self.details,
            logo: logo ?? self.logo,
            name: name ?? self.name,
            operators: operators ?? self.operators
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Details.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let details = try Details(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.detailsTask(with: url) { details, response, error in
//     if let details = details {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDetails { response in
//     if let details = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - Details
struct OperationsDetails: Codable {
    var accountLength: Int?
    var accountType, address: String?
    var check: Bool?
    var chequeName, city, code: String?
    var commissionList: [String]?
    var country: String?
    var currencyList: [String]?
    var detailsDescription: String?
    var isDebtsRequestSupported, isGroup, isMultiStep, isTemplateSavingForbidden: Bool?
    var logotypeList: [LogotypeList]?
    var mask: String?
    var maxSumList: [Int]?
    var mcc: String?
    var minSumList: [Int]?
    var nameList: [NameList]?
    var offLine, order: Int?
    var parameterList: [ParameterList]?
    var parentCode, region, regularExpression: String?
    var sendCheck: Bool?
    var synonymList: [String]?
    var tariffList: [TariffList]?

    enum CodingKeys: String, CodingKey {
        case accountLength, accountType, address, check, chequeName, city, code, commissionList, country, currencyList
        case detailsDescription = "description"
        case isDebtsRequestSupported, isGroup, isMultiStep, isTemplateSavingForbidden, logotypeList, mask, maxSumList, mcc, minSumList, nameList, offLine, order, parameterList, parentCode, region, regularExpression, sendCheck, synonymList, tariffList
    }
}

// MARK: Details convenience initializers and mutators

extension OperationsDetails {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(OperationsDetails.self, from: data)
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
        accountLength: Int?? = nil,
        accountType: String?? = nil,
        address: String?? = nil,
        check: Bool?? = nil,
        chequeName: String?? = nil,
        city: String?? = nil,
        code: String?? = nil,
        commissionList: [String]?? = nil,
        country: String?? = nil,
        currencyList: [String]?? = nil,
        detailsDescription: String?? = nil,
        isDebtsRequestSupported: Bool?? = nil,
        isGroup: Bool?? = nil,
        isMultiStep: Bool?? = nil,
        isTemplateSavingForbidden: Bool?? = nil,
        logotypeList: [LogotypeList]?? = nil,
        mask: String?? = nil,
        maxSumList: [Int]?? = nil,
        mcc: String?? = nil,
        minSumList: [Int]?? = nil,
        nameList: [NameList]?? = nil,
        offLine: Int?? = nil,
        order: Int?? = nil,
        parameterList: [ParameterList]?? = nil,
        parentCode: String?? = nil,
        region: String?? = nil,
        regularExpression: String?? = nil,
        sendCheck: Bool?? = nil,
        synonymList: [String]?? = nil,
        tariffList: [TariffList]?? = nil
    ) -> OperationsDetails {
        return OperationsDetails(
            accountLength: accountLength ?? self.accountLength,
            accountType: accountType ?? self.accountType,
            address: address ?? self.address,
            check: check ?? self.check,
            chequeName: chequeName ?? self.chequeName,
            city: city ?? self.city,
            code: code ?? self.code,
            commissionList: commissionList ?? self.commissionList,
            country: country ?? self.country,
            currencyList: currencyList ?? self.currencyList,
            detailsDescription: detailsDescription ?? self.detailsDescription,
            isDebtsRequestSupported: isDebtsRequestSupported ?? self.isDebtsRequestSupported,
            isGroup: isGroup ?? self.isGroup,
            isMultiStep: isMultiStep ?? self.isMultiStep,
            isTemplateSavingForbidden: isTemplateSavingForbidden ?? self.isTemplateSavingForbidden,
            logotypeList: logotypeList ?? self.logotypeList,
            mask: mask ?? self.mask,
            maxSumList: maxSumList ?? self.maxSumList,
            mcc: mcc ?? self.mcc,
            minSumList: minSumList ?? self.minSumList,
            nameList: nameList ?? self.nameList,
            offLine: offLine ?? self.offLine,
            order: order ?? self.order,
            parameterList: parameterList ?? self.parameterList,
            parentCode: parentCode ?? self.parentCode,
            region: region ?? self.region,
            regularExpression: regularExpression ?? self.regularExpression,
            sendCheck: sendCheck ?? self.sendCheck,
            synonymList: synonymList ?? self.synonymList,
            tariffList: tariffList ?? self.tariffList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// LogotypeList.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let logotypeList = try LogotypeList(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.logotypeListTask(with: url) { logotypeList, response, error in
//     if let logotypeList = logotypeList {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseLogotypeList { response in
//     if let logotypeList = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - LogotypeList
struct LogotypeList: Codable {
    var content, contentType, name: String?
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

// NameList.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let nameList = try NameList(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.nameListTask(with: url) { nameList, response, error in
//     if let nameList = nameList {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseNameList { response in
//     if let nameList = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - NameList
struct NameList: Codable {
    var locale, value: String?
}

// MARK: NameList convenience initializers and mutators

extension NameList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(NameList.self, from: data)
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
        locale: String?? = nil,
        value: String?? = nil
    ) -> NameList {
        return NameList(
            locale: locale ?? self.locale,
            value: value ?? self.value
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// ParameterList.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let parameterList = try ParameterList(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.parameterListTask(with: url) { parameterList, response, error in
//     if let parameterList = parameterList {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseParameterList { response in
//     if let parameterList = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - ParameterList
struct ParameterList: Codable {
    var comment, direction, interfaceType: String?
    var isNotInTemplate, isRequired: Bool?
    var mask: String?
    var maxLength, minLength: Int?
    var name: String?
    var npp: Int?
    var paramGroup: String?
    var rawLength: Int?
    var regularExpression, stepScript, title, type: String?
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
        comment: String?? = nil,
        direction: String?? = nil,
        interfaceType: String?? = nil,
        isNotInTemplate: Bool?? = nil,
        isRequired: Bool?? = nil,
        mask: String?? = nil,
        maxLength: Int?? = nil,
        minLength: Int?? = nil,
        name: String?? = nil,
        npp: Int?? = nil,
        paramGroup: String?? = nil,
        rawLength: Int?? = nil,
        regularExpression: String?? = nil,
        stepScript: String?? = nil,
        title: String?? = nil,
        type: String?? = nil
    ) -> ParameterList {
        return ParameterList(
            comment: comment ?? self.comment,
            direction: direction ?? self.direction,
            interfaceType: interfaceType ?? self.interfaceType,
            isNotInTemplate: isNotInTemplate ?? self.isNotInTemplate,
            isRequired: isRequired ?? self.isRequired,
            mask: mask ?? self.mask,
            maxLength: maxLength ?? self.maxLength,
            minLength: minLength ?? self.minLength,
            name: name ?? self.name,
            npp: npp ?? self.npp,
            paramGroup: paramGroup ?? self.paramGroup,
            rawLength: rawLength ?? self.rawLength,
            regularExpression: regularExpression ?? self.regularExpression,
            stepScript: stepScript ?? self.stepScript,
            title: title ?? self.title,
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

// TariffList.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let tariffList = try TariffList(json)
//
// To read values from URLs:
//
//   let task = URLSession.shared.tariffListTask(with: url) { tariffList, response, error in
//     if let tariffList = tariffList {
//       ...
//     }
//   }
//   task.resume()
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseTariffList { response in
//     if let tariffList = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - TariffList
struct TariffList: Codable {
    var comissionCashless, commission, commissionForeign: String?
    var maxAmount: Int?
    var maxSum: String?
    var minAmount: Int?
    var minMax: String?
    var minSum: Int?
    var region: String?
}

// MARK: TariffList convenience initializers and mutators

extension TariffList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TariffList.self, from: data)
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
        comissionCashless: String?? = nil,
        commission: String?? = nil,
        commissionForeign: String?? = nil,
        maxAmount: Int?? = nil,
        maxSum: String?? = nil,
        minAmount: Int?? = nil,
        minMax: String?? = nil,
        minSum: Int?? = nil,
        region: String?? = nil
    ) -> TariffList {
        return TariffList(
            comissionCashless: comissionCashless ?? self.comissionCashless,
            commission: commission ?? self.commission,
            commissionForeign: commissionForeign ?? self.commissionForeign,
            maxAmount: maxAmount ?? self.maxAmount,
            maxSum: maxSum ?? self.maxSum,
            minAmount: minAmount ?? self.minAmount,
            minMax: minMax ?? self.minMax,
            minSum: minSum ?? self.minSum,
            region: region ?? self.region
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// JSONSchemaSupport.swift

import Foundation

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func operationsListTask(with url: URL, completionHandler: @escaping (OperationsList?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}

// MARK: - Alamofire response handlers


