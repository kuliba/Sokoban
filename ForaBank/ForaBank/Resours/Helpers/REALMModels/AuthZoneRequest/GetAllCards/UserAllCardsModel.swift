//
//  UserAllCardsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.08.2021.
//

import Foundation
import RealmSwift

// MARK: - UserAllCardsModel
class UserAllCardsModel: Object {

    @objc dynamic var number: String?
    @objc dynamic var numberMasked: String?
    @objc dynamic var balance = 0.0
    @objc dynamic var currency: String?
    @objc dynamic var productType: String?
    @objc dynamic var productName: String?
    @objc dynamic var ownerID = 0
    @objc dynamic var accountNumber: String?
    @objc dynamic var allowDebit = false
    @objc dynamic var allowCredit = false
    @objc dynamic var customName: String?
    @objc dynamic var cardID = 0
    @objc dynamic var name: String?
    @objc dynamic var validThru = 0
    @objc dynamic var status: String?
    @objc dynamic var holderName: String?
    @objc dynamic var product: String?
    @objc dynamic var branch: String?
    @objc dynamic var miniStatement: String?
    @objc dynamic var mainField: String?
    @objc dynamic var additionalField: String?
    @objc dynamic var smallDesign: String?
    @objc dynamic var mediumDesign: String?
    @objc dynamic var largeDesign: String?
    @objc dynamic var paymentSystemName: String?
    @objc dynamic var paymentSystemImage: String?
    @objc dynamic var fontDesignColor: String?
    @objc dynamic var id: Int = 0
    var background = List<UserAllCardsbackgroundModel>()
    @objc dynamic var openDate = 0
    @objc dynamic var branchId = 0
    @objc dynamic var accountID = 0
    @objc dynamic var expireDate: String?
    @objc dynamic var XLDesign: String?
    @objc dynamic var statusPC: String?
    @objc dynamic var interestRate: String?
    @objc dynamic var depositProductID: Int = 0
    @objc dynamic var depositID: Int = 0
    @objc dynamic var creditMinimumAmount: Double = 0.0
    @objc dynamic var minimumBalance: Double = 0.0
    @objc dynamic var balanceRUB: Double = 0.0

    
    override static func primaryKey() -> String? {
        return "id"
    }
}    

class UserAllCardsbackgroundModel: Object {
    @objc dynamic var color: String?
}

extension UserAllCardsModel: Identifiable {
    
    convenience init(with data: GetProductListDatum) {
        
        self.init()
        number             = data.number
        numberMasked       = data.numberMasked
        balance            = data.balance ?? 0.0
        currency           = data.currency
        productType        = data.productType
        productName        = data.productName
        ownerID            = data.ownerID ?? 0
        accountNumber      = data.accountNumber
        allowDebit         = data.allowDebit ?? false
        allowCredit        = data.allowCredit ?? false
        customName         = data.customName
        cardID             = data.cardID ?? 0
        name               = data.name
        validThru          = data.validThru ?? 0
        status             = data.status
        holderName         = data.holderName
        product            = data.product
        branch             = data.branch
        mainField          = data.mainField
        additionalField    = data.additionalField
        smallDesign        = data.smallDesign
        mediumDesign       = data.mediumDesign
        largeDesign        = data.largeDesign
        paymentSystemName  = data.paymentSystemName
        paymentSystemImage = data.paymentSystemImage
        fontDesignColor    = data.fontDesignColor
        id                 = data.id ?? 0
        openDate           = data.openDate ?? 0
        branchId           = data.branchId ?? 0
        accountID          = data.accountID ?? 0
        expireDate         = data.expireDate
        XLDesign           = data.XLDesign
        statusPC           = data.statusPC
        interestRate       = "\(data.interestRate ?? 0.0)"
        depositProductID   = data.depositProductID ?? 0
        depositID          = data.depositID ?? 0
        creditMinimumAmount = data.creditMinimumAmount ?? 0.0
        minimumBalance     = data.minimumBalance ?? 0.0
        balanceRUB         = data.balanceRUB ?? 0.0
        
        data.background.forEach { color in
            
            background.append(UserAllCardsbackgroundModel(with: color))
        }
    }
}

extension UserAllCardsbackgroundModel {
    
    convenience init(with color: String?) {
        
        self.init()
        self.color = color
    }
}

extension UserAllCardsModel {
    
    var productTypeEnum: ProductType {
        
        guard let productType = productType, let productTypeEnum = ProductType(rawValue: productType) else {
            
            //FIXME: dirty hack for refactoring period!!!
            return .account
        }
        
        return productTypeEnum
    }
}
