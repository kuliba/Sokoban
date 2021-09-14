//
//  GetProductListByFilter.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetProductListByFilter
class GetProductListByFilter: Object {
    
    @objc dynamic var XLDesign: String?
    @objc dynamic var accountNumber: String?
    @objc dynamic var additionalField: String?
    @objc dynamic var allowCredit: String?
    @objc dynamic var allowDebit: String?
    @objc dynamic var balance: String?
    @objc dynamic var currency: String?
    @objc dynamic var customName: String?
    @objc dynamic var fontDesignColor: String?
    @objc dynamic var id: String?
    @objc dynamic var largeDesign: String?
    @objc dynamic var mainField: String?
    @objc dynamic var mediumDesign: String?
    @objc dynamic var number: String?
    @objc dynamic var numberMasked: String?
    @objc dynamic var ownerID: String?
    @objc dynamic var productName: String?
    @objc dynamic var productType: String?
    @objc dynamic var smallDesign: String?
    
    var background = List<GetProductListByFilterList>()
}

//// MARK: - GetProductListByFilterList
class GetProductListByFilterList: Object {
    
    @objc dynamic var background: String?
}

