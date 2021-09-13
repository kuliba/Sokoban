//
//  GetBankList.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetBankList
class GetBankList: Object {
    
    @objc dynamic var serial: String?
    
    var banksList = List<BankList>()
}

//// MARK: - BankList
class BankList: Object {
    
    @objc dynamic var memberId: String?
    @objc dynamic var name: String?
    @objc dynamic var fullName: String?
    @objc dynamic var engName : String?
    @objc dynamic var rusName : String?
    @objc dynamic var svgImage : String?
    @objc dynamic var bic: String?
    @objc dynamic var fiasId: String?
    @objc dynamic var address: String?
    @objc dynamic var latitude : String?
    @objc dynamic var longitude : String?
    @objc dynamic var inn : String?
    @objc dynamic var kpp: String?
    @objc dynamic var registrationNumber: String?
    @objc dynamic var registrationDate: String?
    @objc dynamic var bankType : String?
    @objc dynamic var bankTypeCode : String?
    @objc dynamic var bankServiceType : String?
    @objc dynamic var bankServiceTypeCode : String?
    
    var accountList = List<BankAccauntList>()
}

//// MARK: - BankAccauntList
class BankAccauntList: Object {
    
    @objc dynamic var account: String?
    @objc dynamic var regulationAccountType: String?
    @objc dynamic var ck: String?
    @objc dynamic var dateIn : String?
    @objc dynamic var dateOut : String?
    @objc dynamic var status : String?
    @objc dynamic var CBRBIC : String?
    
}
