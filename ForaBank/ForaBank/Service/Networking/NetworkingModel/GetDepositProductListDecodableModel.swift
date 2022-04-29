//
//  OpenDepositDecodableModel.swift
//  ForaBank
//
//  Created by Mikhail on 30.11.2021.
//

import Foundation


// MARK: - OpenDepositDecodableModel
struct GetDepositProductListDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [OpenDepositDatum]?
}

// MARK: OpenDepositDecodableModel convenience initializers and mutators

extension GetDepositProductListDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetDepositProductListDecodableModel.self, from: data)
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
        data: [OpenDepositDatum]?? = nil
    ) -> GetDepositProductListDecodableModel {
        return GetDepositProductListDecodableModel(
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

// MARK: - OpenDepositDatum
struct OpenDepositDatum: Codable {
    let depositProductID: Int?
    let name: String?
    let generalСondition: GeneralСondition?
    let detailedСonditions: [DetailedСondition]?
    let txtСondition: [String]?
    let termRateList: [DatumTermRateList]?
    let termRateCapList: [DatumTermRateList]?
    let documentsList: [DocumentsList]?
}

// MARK: OpenDepositDatum convenience initializers and mutators

extension OpenDepositDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(OpenDepositDatum.self, from: data)
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
        depositProductID: Int?? = nil,
        name: String?? = nil,
        generalСondition: GeneralСondition?? = nil,
        detailedСonditions: [DetailedСondition]?? = nil,
        txtСondition: [String]?? = nil,
        termRateList: [DatumTermRateList]?? = nil,
        termRateCapList: [DatumTermRateList]?? = nil,
        documentsList: [DocumentsList]?? = nil
    ) -> OpenDepositDatum {
        return OpenDepositDatum(
            depositProductID: depositProductID ?? self.depositProductID,
            name: name ?? self.name,
            generalСondition: generalСondition ?? self.generalСondition,
            detailedСonditions: detailedСonditions ?? self.detailedСonditions,
            txtСondition: txtСondition ?? self.txtСondition,
            termRateList: termRateList ?? self.termRateList,
            termRateCapList: termRateCapList ?? self.termRateCapList,
            documentsList: documentsList ?? self.documentsList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - DetailedСondition
struct DetailedСondition: Codable {
    let enable: Bool?
    let desc: String?
}

// MARK: DetailedСondition convenience initializers and mutators

extension DetailedСondition {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DetailedСondition.self, from: data)
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
        enable: Bool?? = nil,
        desc: String?? = nil
    ) -> DetailedСondition {
        return DetailedСondition(
            enable: enable ?? self.enable,
            desc: desc ?? self.desc
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - DocumentsList
struct DocumentsList: Codable {
    let url: String?
    let name: String?
}

// MARK: DocumentsList convenience initializers and mutators

extension DocumentsList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DocumentsList.self, from: data)
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
        url: String?? = nil,
        name: String?? = nil
    ) -> DocumentsList {
        return DocumentsList(
            url: url ?? self.url,
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

// MARK: - GeneralСondition
struct GeneralСondition: Codable {
    let maxRate: Double?
    let minSum, maxSum, minTerm: Int?
    let maxTerm: Int?
    let maxTermTxt: String?
    let imageLink: String?
    let design: Design?
    let formula: String?
    let сurrencyCode, generalTxtСondition: [String]?
}

// MARK: GeneralСondition convenience initializers and mutators

extension GeneralСondition {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GeneralСondition.self, from: data)
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
        maxRate: Double?? = nil,
        minSum: Int?? = nil,
        maxSum: Int?? = nil,
        minTerm: Int?? = nil,
        maxTerm: Int?? = nil,
        maxTermTxt: String?? = nil,
        imageLink: String?? = nil,
        design: Design?? = nil,
        formula: String?? = nil,
        сurrencyCode: [String]?? = nil,
        generalTxtСondition: [String]?? = nil
    ) -> GeneralСondition {
        return GeneralСondition(
            maxRate: maxRate ?? self.maxRate,
            minSum: minSum ?? self.minSum,
            maxSum: maxSum ?? self.maxSum,
            minTerm: minTerm ?? self.minTerm,
            maxTerm: maxTerm ?? self.maxTerm,
            maxTermTxt: maxTermTxt ?? self.maxTermTxt,
            imageLink: imageLink ?? self.imageLink,
            design: design ?? self.design,
            formula: formula ?? self.formula,
            сurrencyCode: сurrencyCode ?? self.сurrencyCode,
            generalTxtСondition: generalTxtСondition ?? self.generalTxtСondition
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Design
struct Design: Codable {
    let textColor, background: [String]?
}

// MARK: Design convenience initializers and mutators

extension Design {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Design.self, from: data)
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
        textColor: [String]?? = nil,
        background: [String]?? = nil
    ) -> Design {
        return Design(
            textColor: textColor ?? self.textColor,
            background: background ?? self.background
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - DatumTermRateList
struct DatumTermRateList: Codable {
    let сurrencyCode: String?
    let сurrencyCodeTxt: String?
    let termRateSum: [TermRateSum]?
}

// MARK: DatumTermRateList convenience initializers and mutators

extension DatumTermRateList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DatumTermRateList.self, from: data)
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
        сurrencyCode: String?? = nil,
        сurrencyCodeTxt: String?? = nil,
        termRateSum: [TermRateSum]?? = nil
    ) -> DatumTermRateList {
        return DatumTermRateList(
            сurrencyCode: сurrencyCode ?? self.сurrencyCode,
            сurrencyCodeTxt: сurrencyCodeTxt ?? self.сurrencyCodeTxt,
            termRateSum: termRateSum ?? self.termRateSum
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - TermRateSum
struct TermRateSum: Codable {
    let sum: Int?
    let termRateList: [TermRateSumTermRateList]?
}

// MARK: TermRateSum convenience initializers and mutators

extension TermRateSum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TermRateSum.self, from: data)
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
        sum: Int?? = nil,
        termRateList: [TermRateSumTermRateList]?? = nil
    ) -> TermRateSum {
        return TermRateSum(
            sum: sum ?? self.sum,
            termRateList: termRateList ?? self.termRateList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - TermRateSumTermRateList
struct TermRateSumTermRateList: Codable {
    let term: Int?
    let rate: Double?
    let termName: String?
}

// MARK: TermRateSumTermRateList convenience initializers and mutators

extension TermRateSumTermRateList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TermRateSumTermRateList.self, from: data)
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
        term: Int?? = nil,
        rate: Double?? = nil,
        termName: String?? = nil
    ) -> TermRateSumTermRateList {
        return TermRateSumTermRateList(
            term: term ?? self.term,
            rate: rate ?? self.rate,
            termName: termName ?? self.termName
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public struct WordDeclensionEnum {
     let day = ["день", "дня", "дней"]
}

public class WordDeclensionUtil {
    
    class func getWordInDeclension(type: [String] ,n: Int?) -> String {
        guard let n = n else { return "" }
        // смотрим две последние цифры
        var result: Int = n % 100
        
        if (result >= 10 && result <= 20) {
            // если окончание 11 - 20
            return type[2]
        }
        
        // смотрим одну последнюю цифру
        result = n % 10;
        if (result == 0 || result > 4) {
            return type[2]
        }
        if (result > 1) {
            return type[1]
        }
        if (result == 1) {
            return type[0]
        }
        return ""
    }
    
}
