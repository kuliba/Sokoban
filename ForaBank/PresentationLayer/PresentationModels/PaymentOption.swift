

import Foundation

struct PaymentOption: IPickerItem, IPresentationModel {

    var title: String {
        get {
//            if provider == "ACCOUNT"{
//                return productName ?? ""
//            } else {
//            return name ?? ""
//            }
            return name ?? ""

        }
    }

    var subTitle: String {
        get {
//            if provider == "ACCOUNT" || provider == "CARD"{
//                return accountNumber ?? ""
//            } else {
//                return maskedNumber
//            }
//            return  maskedAccountNumber(number: self.accountNumber ?? "", separator: ".")
            return maskedNumber.dropFirst(10).description.replace(string: "X", replacement: "·").replace(string: "-", replacement: " ")
        }
    }

    var value: Double {
        get {
            return sum
        }
    }
    
    var accountNumberSBP: String{
        get{
            return accountNumber ?? ""
        }
//        set{
//            return accountNumber
//        }
    }
//    var currencyCode: String? {
//        get{
//            return currency
//        }
//
//    }
    var productName: String?
    var itemType: PickerItemType
    let id: Double
    var name: String?
    var type: RemittanceOptionViewType
    var sum: Double
    let number: String
    let maskSum: String
    var maskedNumber: String
    let provider: String?
    let productType: ProductType
    var currencyCode: String?
    var accountNumber: String?
    
    init(id: Double, name: String?, type: PickerItemType, sum: Double, number: String, maskedNumber: String, provider: String, productType: ProductType, maskSum: String, currencyCode: String, accountNumber: String?, productName: String?) {
        self.id = id
        self.name = name
        self.sum = sum
        self.number = number
        self.maskedNumber = maskedNumber
        self.type = .custom
        self.provider = provider
        self.itemType = type
        self.productType = productType
        self.maskSum = maskSum
        self.currencyCode = currencyCode
        self.accountNumber = accountNumber
        self.productName = productName
    }

    init(product: IProduct) {
        id = product.id
        name = product.name ?? ""
        sum = product.balance
        number = product.number
        maskedNumber = product.maskedNumber
        provider = nil
        type = .custom
        maskSum = ForaBank.maskSum(sum: product.balance)
        currencyCode = product.currencyCode
        accountNumber = maskedAccountNumber(number: product.accountNumber, separator: ".")
        productName = product.accountNumber

        switch product {
        case is Card, is Deposit, is Account:
            itemType = .paymentOption
            maskedNumber = maskedAccountNumber(number: self.accountNumber ?? "", separator: ".")
            break
        default:
            itemType = .plain
            break
        }
        
        switch product {
        case is Card:
            productType = .card
            maskedNumber = self.accountNumber ?? ""
            break
        case is Deposit:
            productType = .deposit
            break
        case is Account:
            productType = .account
            break
        default:
            productType = .loan
            break
        }
    }
}
