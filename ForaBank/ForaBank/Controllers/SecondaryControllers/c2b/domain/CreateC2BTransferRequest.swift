// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let createC2BTransferRequest = try? newJSONDecoder().decode(CreateC2BTransferRequest.self, from: jsonData)

import Foundation

// MARK: - CreateC2BTransferRequest
struct CreateC2BTransferRequest {
    let statusCode: Int?
    let errorMessage: String?
    let data: DataClass2?
}

// MARK: - DataClass
struct DataClass2 {
    let needMake, needOTP: Bool?
    let amount: Int?
    let creditAmount: String?
    let fee: Int?
    let currencyAmount, currencyPayer, currencyPayee: String?
    let currencyRate: String?
    let debitAmount: Int?
    let payeeName: String?
    let paymentOperationDetailID: Int?
    let documentStatus: String?
    let needSum: Bool?
    let additionalList, parameterListForNextStep: [Any?]?
    let finalStep: Bool?
    let infoMessage: String?
}

