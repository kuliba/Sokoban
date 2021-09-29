//
//  GetLatestMobilePaymentsDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 29.09.2021.
//

import Foundation

// MARK: - GetLatestMobilePaymentsDecodableModel
struct GetLatestMobilePaymentsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetLatestMobilePaymentsDatum]?
}

// MARK: GetLatestMobilePaymentsDecodableModel convenience initializers and mutators

extension GetLatestMobilePaymentsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestMobilePaymentsDecodableModel.self, from: data)
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
        data: [GetLatestMobilePaymentsDatum]?? = nil
    ) -> GetLatestMobilePaymentsDecodableModel {
        return GetLatestMobilePaymentsDecodableModel(
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


// MARK: - GetLatestMobilePaymentsDatum
struct GetLatestMobilePaymentsDatum: Codable {
    let paymentDate: String?
    let date: Int?
    let amount: Double?
    let puref: String?
    let additionalList: [GetLatestMobilePaymentsAdditionalList]?
}

// MARK: Datum convenience initializers and mutators

extension GetLatestMobilePaymentsDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestMobilePaymentsDatum.self, from: data)
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
        amount: Double?? = nil,
        puref: String?? = nil,
        additionalList: [GetLatestMobilePaymentsAdditionalList]?? = nil
    ) -> GetLatestMobilePaymentsDatum {
        return GetLatestMobilePaymentsDatum(
            paymentDate: paymentDate ?? self.paymentDate,
            date: date ?? self.date,
            amount: amount ?? self.amount,
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

// MARK: - GetLatestMobilePaymentsAdditionalList
struct GetLatestMobilePaymentsAdditionalList: Codable {
    let fieldName, fieldValue: String?
}

// MARK: GetLatestMobilePaymentsAdditionalList convenience initializers and mutators

extension GetLatestMobilePaymentsAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestMobilePaymentsAdditionalList.self, from: data)
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
    ) -> GetLatestMobilePaymentsAdditionalList {
        return GetLatestMobilePaymentsAdditionalList(
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
