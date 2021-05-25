
import Foundation

protocol IProduct {
    var id: Double { get }
    var balance: Double { get }
    var number: String { get }
    var maskedNumber: String { get }
    var currencyCode: String { get }
    var accountNumber : String { get }
    var name: String? { get }
}

protocol ICustomName {
    var customName: String { get }
}

protocol IProductAccount {
    var accountNumber: String { get }
}
protocol IProductLoan {
    var accountNumber: String { get }
}

