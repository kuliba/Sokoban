//
//  GetClientConsentMe2MePullDecodableModel.swift
//  ForaBank
//
//  Created by Mikhail on 29.08.2021.
//

import Foundation

// MARK: - GetClientConsentMe2MePullDecodableModel
struct GetClientConsentMe2MePullDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: GetConsentListDatum?
}

// MARK: GetFullBankInfoListDecodableModel convenience initializers and mutators

extension GetClientConsentMe2MePullDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetClientConsentMe2MePullDecodableModel.self, from: data)
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
        data: GetConsentListDatum?? = nil
    ) -> GetClientConsentMe2MePullDecodableModel {
        return GetClientConsentMe2MePullDecodableModel(
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

// MARK: - GetConsentListDatum
struct GetConsentListDatum: Codable {
    let consentList: [ConsentList]?
}


// MARK: Datum convenience initializers and mutators

extension GetConsentListDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetConsentListDatum.self, from: data)
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
        consentList: [ConsentList]? = nil
    ) -> GetConsentListDatum {
        return GetConsentListDatum (
            consentList: consentList ?? self.consentList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ConsentList
struct ConsentList: Codable {
    let active: Bool?
    let bankId: String?
    let beginDate: String?
    let consentId: Int?
    let endDate: String?
    let oneTimeConsent: Bool?
}

// MARK: ConsentList convenience initializers and mutators

extension ConsentList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ConsentList.self, from: data)
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
        active: Bool?? = nil,
        bankId: String?? = nil,
        beginDate: String?? = nil,
        consentId: Int?? = nil,
        endDate: String?? = nil,
        oneTimeConsent: Bool?? = nil
    ) -> ConsentList {
        return ConsentList(
            active: active ?? self.active,
            bankId: bankId ?? self.bankId,
            beginDate: beginDate ?? self.beginDate,
            consentId: consentId ?? self.consentId,
            endDate: endDate ?? self.endDate,
            oneTimeConsent: oneTimeConsent ?? self.oneTimeConsent
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
