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

    @Persisted var number: String?
    @Persisted var numberMasked: String?
    @Persisted var balance = 0.0
    @Persisted var currency: String?
    @Persisted var productType: String?
    @Persisted var productName: String?
    @Persisted var ownerID = 0
    @Persisted var accountNumber: String?
    @Persisted var allowDebit = false
    @Persisted var allowCredit = false
    @Persisted var customName: String?
    @Persisted var cardID = 0
    @Persisted var name: String?
    @Persisted var validThru = 0
    @Persisted var status: String?
    @Persisted var holderName: String?
    @Persisted var product: String?
    @Persisted var branch: String?
    @Persisted var miniStatement: String?
    @Persisted var mainField: String?
    @Persisted var additionalField: String?
    @Persisted var smallDesign: String?
    @Persisted var mediumDesign: String?
    @Persisted var largeDesign: String?
    @Persisted var paymentSystemName: String?
    @Persisted var paymentSystemImage: String?
    @Persisted var fontDesignColor: String?
    @Persisted var id: Int = 0
    
}
