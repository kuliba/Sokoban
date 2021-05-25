// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let anywayPaymentBegin = try? newJSONDecoder().decode(AnywayPaymentBegin.self, from: jsonData)

import Foundation

// MARK: - AnywayPaymentBegin
class AnywayPaymentBegin: Codable {
    let data: Int?
    let errorMessage, result: String?

    init(data: Int?, errorMessage: String?, result: String?) {
        self.data = data
        self.errorMessage = errorMessage
        self.result = result
    }
}
