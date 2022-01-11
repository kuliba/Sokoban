// GetOperationDetailDecodebleModel.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let getOperationDetailDecodebleModel = try GetOperationDetailDecodebleModel(json)

import Foundation

// MARK: - GetOperationDetailDecodebleModel
struct GetOperationDetailDecodebleModel: Codable, NetworkModelProtocol {
    let statusCode: Int?
    let errorMessage: String?
    let data: OperationDetailDatum?

    enum CodingKeys: String, CodingKey {
        case statusCode, errorMessage, data
    }
}

// MARK: GetOperationDetailDecodebleModel convenience initializers and mutators

extension GetOperationDetailDecodebleModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GetOperationDetailDecodebleModel.self, from: data)
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
        data: OperationDetailDatum?? = nil
    ) -> GetOperationDetailDecodebleModel {
        return GetOperationDetailDecodebleModel(
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

// OperationDetailDatum.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let operationDetailDatum = try OperationDetailDatum(json)

import Foundation

// MARK: - OperationDetailDatum
struct OperationDetailDatum: Codable {
    
    let payeeFullName, payeeFirstName, payeeMiddleName, payeeSurName, payeePhone, payeeCardNumber: String?
    let payeeAmount, amount: Double?
    let claimID, transferDate, responseDate: String?
    let currencyAmount: String?
    let payerFee: Double?
    let fullAmount: Double?
    let payerAccountNumber, payerCurrency, payerCardNumber, payeeBankName: String?
    let payerFullName, payerDocument, requestDate: String?
    let payerAmount: Double?
    let paymentOperationDetailID: Int?
    let printFormType, dateForDetail, memberID: String?, transferEnum: String?
    let transferReference: String?
    let account: String?
    let payeeAccountNumber: String?
    let countryName: String?
    let payeeBankBIC: String?
    let payeeINN: String?
    let payeeKPP: String?
    let provider: String?
    let period: String?
    let transferNumber: String?

    enum CodingKeys: String, CodingKey {
        
        case payeeFullName, payeeFirstName, payeeMiddleName, payeeSurName, payeePhone, payeeCardNumber
        case payeeAmount, amount
        case claimID = "claimId", transferDate, responseDate
        case currencyAmount
        case payerFee
        case fullAmount
        case payerAccountNumber, payerCurrency, payerCardNumber, payeeBankName
        case payerFullName, payerDocument, requestDate
        case payerAmount
        case paymentOperationDetailID = "paymentOperationDetailId"
        case printFormType, dateForDetail, memberID = "memberId", transferEnum
        case transferReference
        case account
        case payeeAccountNumber
        case countryName
        case payeeBankBIC
        case payeeINN
        case payeeKPP
        case provider
        case period
        case transferNumber
    }
}

