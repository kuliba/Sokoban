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
    @objc dynamic var memberName: String?
    @objc dynamic var memberNameRus: String?
    @objc dynamic var md5hash : String?
    @objc dynamic var svgImage : String?
    var paymentSystemCodeList = List<String>()
}
