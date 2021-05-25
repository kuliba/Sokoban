// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let preparePayment = try? newJSONDecoder().decode(PreparePayment.self, from: jsonData)

import Foundation

// MARK: - PreparePayment
struct PreparePayment {
    let result: String
    let errorMessage: String?
    let data: DataClass
}

// MARK: - DataClass
struct DataClassPayment {
    var payerCardNumber: String?
    var payerAccountNumber, payeeCardNumber, payeeAccountNumber, payeePhone: String?
    var payeeName: String?
    var amount: Int?
    var currencyAmount: String?
    var commission: [JSONAny?]
    

}

// MARK: - Encode/decode helpers
