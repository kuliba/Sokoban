import Foundation

class GlobalModule {
    static let UTILITIES_CODE = "1031001"
    static let INTERNET_TV_CODE = "1051001"
    static let PAYMENT_TRANSPORT = "1051062"
    static var qrOperator: GKHOperatorsModel?
    static var qrData: [String: String]?
    static var c2bURL: String? = nil
}
