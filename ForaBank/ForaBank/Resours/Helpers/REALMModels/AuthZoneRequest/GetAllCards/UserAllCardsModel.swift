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
    
}

class UserAllCardsbackgroundModel: Object {
    @objc dynamic var color: String?
}
