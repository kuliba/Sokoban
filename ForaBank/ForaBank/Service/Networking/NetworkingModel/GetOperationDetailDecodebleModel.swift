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
    let payeeFullName, payeePhone, payeeCurrency, payeeCardNumber: String?
    let payeeAmount: Double?
    let claimID, transferDate, responseDate: String?
    let payerFee: Double?
    let fullAmount: Double?
    let payerAccountNumber, payerCurrency, payerCardNumber, payeeBankName: String?
    let payerFullName, payerDocument, requestDate: String?
    let payerAmount: Double?
    let paymentOperationDetailID: Int?
    let printFormType, dateForDetail, memberID: String?

    enum CodingKeys: String, CodingKey {
        case payeeFullName, payeePhone, payeeCurrency, payeeAmount, payeeCardNumber
        case claimID = "claimId"
        case transferDate, responseDate, payerFee, fullAmount, payerAccountNumber, payerCurrency, payerCardNumber, payeeBankName, payerFullName, payerDocument, requestDate, payerAmount
        case paymentOperationDetailID = "paymentOperationDetailId"
        case printFormType, dateForDetail
        case memberID = "memberId"
    }
}

// MARK: OperationDetailDatum convenience initializers and mutators

extension OperationDetailDatum {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(OperationDetailDatum.self, from: data)
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
        payeeFullName: String?? = nil,
        payeeCardNumber: String?? = nil,
        payeePhone: String?? = nil,
        payeeCurrency: String?? = nil,
        payeeAmount: Double?? = nil,
        claimID: String?? = nil,
        transferDate: String?? = nil,
        responseDate: String?? = nil,
        payerFee: Double?? = nil,
        fullAmount: Double?? = nil,
        payerAccountNumber: String?? = nil,
        payerCurrency: String?? = nil,
        payerCardNumber: String?? = nil,
        payeeBankName: String?? = nil,
        payerFullName: String?? = nil,
        payerDocument: String?? = nil,
        requestDate: String?? = nil,
        payerAmount: Double?? = nil,
        paymentOperationDetailID: Int?? = nil,
        printFormType: String?? = nil,
        dateForDetail: String?? = nil,
        memberID: String?? = nil
    ) -> OperationDetailDatum {
        return OperationDetailDatum(
            payeeFullName: payeeFullName ?? self.payeeFullName,
            payeePhone: payeeCardNumber ?? self.payeeCardNumber,
            payeeCurrency: payeePhone ?? self.payeePhone,
            payeeCardNumber: payeeCurrency ?? self.payeeCurrency,
            payeeAmount: payeeAmount ?? self.payeeAmount,
            claimID: claimID ?? self.claimID,
            transferDate: transferDate ?? self.transferDate,
            responseDate: responseDate ?? self.responseDate,
            payerFee: payerFee ?? self.payerFee,
            fullAmount: fullAmount ?? self.fullAmount,
            payerAccountNumber: payerAccountNumber ?? self.payerAccountNumber,
            payerCurrency: payerCurrency ?? self.payerCurrency,
            payerCardNumber: payerCardNumber ?? self.payerCardNumber,
            payeeBankName: payeeBankName ?? self.payeeBankName,
            payerFullName: payerFullName ?? self.payerFullName,
            payerDocument: payerDocument ?? self.payerDocument,
            requestDate: requestDate ?? self.requestDate,
            payerAmount: payerAmount ?? self.payerAmount,
            paymentOperationDetailID: paymentOperationDetailID ?? self.paymentOperationDetailID,
            printFormType: printFormType ?? self.printFormType,
            dateForDetail: dateForDetail ?? self.dateForDetail,
            memberID: memberID ?? self.memberID
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


