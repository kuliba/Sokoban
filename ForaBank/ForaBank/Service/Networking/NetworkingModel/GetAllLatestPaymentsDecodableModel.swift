//
//  GetAllLatestPaymentsDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.10.2021.
//

import Foundation

// MARK: - GetAllLatestPaymentsDecodableModel
struct GetAllLatestPaymentsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetAllLatestPaymentsDatum]?
}

// MARK: GetAllLatestPaymentsDecodableModel convenience initializers and mutators

extension GetAllLatestPaymentsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAllLatestPaymentsDecodableModel.self, from: data)
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
        data: [GetAllLatestPaymentsDatum]?? = nil
    ) -> GetAllLatestPaymentsDecodableModel {
        return GetAllLatestPaymentsDecodableModel(
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

// MARK: - Datum
struct GetAllLatestPaymentsDatum: Codable {
    let paymentDate: String?
    let date: Int?
    let phoneNumber: String?
    let bankName, bankID: String?
    let amount: Amount?
    let surName, firstName, middleName, shortName: String?
    let countryName, countryCode, puref: String?
    let additionalList: [GetAllLatestPaymentsAdditionalList]?

    enum CodingKeys: String, CodingKey {
        case paymentDate, date, phoneNumber, bankName
        case bankID = "bankId"
        case amount, surName, firstName, middleName, shortName, countryName, countryCode, puref, additionalList
    }
}

// MARK: GetAllLatestPaymentsDatum convenience initializers and mutators

extension GetAllLatestPaymentsDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAllLatestPaymentsDatum.self, from: data)
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
        paymentDate: String?? = nil,
        date: Int?? = nil,
        phoneNumber: String?? = nil,
        bankName: String?? = nil,
        bankID: String?? = nil,
        amount: Amount?? = nil,
        surName: String?? = nil,
        firstName: String?? = nil,
        middleName: String?? = nil,
        shortName: String?? = nil,
        countryName: String?? = nil,
        countryCode: String?? = nil,
        puref: String?? = nil,
        additionalList: [GetAllLatestPaymentsAdditionalList]?? = nil
    ) -> GetAllLatestPaymentsDatum {
        return GetAllLatestPaymentsDatum (
            paymentDate: paymentDate ?? self.paymentDate,
            date: date ?? self.date,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            bankName: bankName ?? self.bankName,
            bankID: bankID ?? self.bankID,
            amount: amount ?? self.amount,
            surName: surName ?? self.surName,
            firstName: firstName ?? self.firstName,
            middleName: middleName ?? self.middleName,
            shortName: shortName ?? self.shortName,
            countryName: countryName ?? self.countryName,
            countryCode: countryCode ?? self.countryCode,
            puref: puref ?? self.puref,
            additionalList: additionalList ?? self.additionalList
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - GetAllLatestPaymentsAdditionalList
struct GetAllLatestPaymentsAdditionalList: Codable {
    let fieldName, fieldValue: String?
}

// MARK: AdditionalList convenience initializers and mutators

extension GetAllLatestPaymentsAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetAllLatestPaymentsAdditionalList.self, from: data)
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
        fieldName: String?? = nil,
        fieldValue: String?? = nil
    ) -> GetAllLatestPaymentsAdditionalList {
        return GetAllLatestPaymentsAdditionalList(
            fieldName: fieldName ?? self.fieldName,
            fieldValue: fieldValue ?? self.fieldValue
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// Amount.swift

import Foundation

enum Amount: Codable {
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Amount.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Amount"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
