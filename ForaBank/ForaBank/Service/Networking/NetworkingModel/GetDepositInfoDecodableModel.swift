import Foundation

// MARK: - DepositInfoGetDepositInfoDecodebleModel
struct DepositInfoGetDepositInfoDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: DepositInfoData?
}

// MARK: DepositInfoGetDepositInfoDecodebleModel convenience initializers and mutators

extension DepositInfoGetDepositInfoDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DepositInfoGetDepositInfoDecodebleModel.self, from: data)
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
        data: DepositInfoData?? = nil
    ) -> DepositInfoGetDepositInfoDecodebleModel {
        return DepositInfoGetDepositInfoDecodebleModel(
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

// DepositInfoData.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let depositInfoData = try DepositInfoData(json)

import Foundation

// MARK: - DepositInfoData
struct DepositInfoData: Codable {
    let dateNext: Int?
    let dateEnd: Int?
    let id: Int?
    let dateOpen: Int?
    let initialAmount, interestRate, sumAccInt, sumCredit, sumDebit, sumPayInt: Double?
    let termDay: String?
}

// MARK: DepositInfoData convenience initializers and mutators

extension DepositInfoData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(DepositInfoData.self, from: data)
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
        dateEnd: Int?? = nil,
        dateNext: Int?? = nil,
        dateOpen: Int?? = nil,
        id: Int?? = nil,
        initialAmount: Double?? = nil,
        interestRate: Double?? = nil,
        sumAccInt: Double?? = nil,
        sumCredit: Double?? = nil,
        sumDebit: Double?? = nil,
        sumPayInt: Double?? = nil,
        termDay: String?? = nil
    ) -> DepositInfoData {
        return DepositInfoData(
            dateNext: dateNext ?? self.dateNext,
            dateEnd: dateEnd ?? self.dateEnd,
            id: dateOpen ?? self.dateOpen,
            dateOpen: id ?? self.id,
            initialAmount: initialAmount ?? self.initialAmount,
            interestRate: interestRate ?? self.interestRate,
            sumAccInt: sumAccInt ?? self.sumAccInt,
            sumCredit: sumCredit ?? self.sumCredit,
            sumDebit: sumDebit ?? self.sumDebit,
            sumPayInt: sumPayInt ?? self.sumPayInt,
            termDay: termDay ?? self.termDay
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


