//
//  GetLatestServicePaymentsDecodableModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation

// MARK: - GetLatestServicePaymentsDecodableModel
struct GetLatestServicePaymentsDecodableModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: [GetLatestServicePaymentsDatum]?
}

// MARK: GetLatestServicePaymentsDecodableModel convenience initializers and mutators

extension GetLatestServicePaymentsDecodableModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestServicePaymentsDecodableModel.self, from: data)
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
        data: [GetLatestServicePaymentsDatum]?? = nil
    ) -> GetLatestServicePaymentsDecodableModel {
        return GetLatestServicePaymentsDecodableModel(
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

// MARK: - GetLatestServicePaymentsDatum
struct GetLatestServicePaymentsDatum: Codable {
    let paymentDate: String?
    let amount: Double?
    let puref: String?
    let additionalList: [GetLatestAdditionalList]?
}

extension GetLatestServicePaymentsDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestServicePaymentsDatum.self, from: data)
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
        amount: Double?? = nil,
        puref: String?? = nil,
        additionalList: [GetLatestAdditionalList]?? = nil
    ) -> GetLatestServicePaymentsDatum {
        return GetLatestServicePaymentsDatum (
            paymentDate: paymentDate ?? self.paymentDate,
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

// MARK: - AdditionalList
struct GetLatestAdditionalList: Codable {
    let fieldName, fieldValue: String?
}

// MARK: AdditionalList convenience initializers and mutators

extension GetLatestAdditionalList {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetLatestAdditionalList.self, from: data)
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
    ) -> GetLatestAdditionalList {
        return GetLatestAdditionalList(
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
