

import Foundation
import Mapper

class Product: Mappable, IProduct {

    enum ProductStatus: String {
        case active = "Действует"
        case NOT_BLOCKED = "NOT_BLOCKED"
    }

    var id: Double {
        return 0 ///Узнавать у Крюкова
    }
    var maskedNumber: String {
        return numberMasked
    }
    var number: String
    var numberMasked: String
    var balance: Double
    var currencyCode: String
    var productType: ProductType
    var productName: String
    var ownerID: Int
    var accountNumber: String
    var allowDebit: Bool
    var allowCredit: Bool
    var cardID: Int?
    var validThru: Int?
    var holderName: String?
    var product: String?
    var branchName: String?
    var name: String?
    var status: ProductStatus?

    required init(map: Mapper) throws {
        try number = map.from("number")
        try numberMasked = map.from("numberMasked")
        try balance = map.from("balance")
        try currencyCode = map.from("currency")
        try productType = map.from("productType")
        try productName = map.from("productName")
        try ownerID = map.from("ownerID")
        try accountNumber = map.from("accountNumber")
        try allowDebit = map.from("allowDebit")
        try allowCredit = map.from("allowCredit")

        validThru = map.optionalFrom("validThru")
        cardID = map.optionalFrom("cardID")
        holderName = map.optionalFrom("holderName")
        product = map.optionalFrom("product")
        branchName = map.optionalFrom("branchName")
        name = map.optionalFrom("name")
        status = map.optionalFrom("status")
    }
}
