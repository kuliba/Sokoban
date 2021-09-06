//
//  GetCountriesList.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetBankList
class GetCountries: Object {
    
    @objc dynamic var serial: String?
    
    var countriesList = List<GetCountriesList>()
}

//// MARK: - BankList
class GetCountriesList: Object {
    
    @objc dynamic var code: String?
    @objc dynamic var contactCode: String?
    @objc dynamic var name: String?
    @objc dynamic var sendCurr: String?
    @objc dynamic var md5hash : String?
    @objc dynamic var svgImage : String?
    var paymentSystemIdList = List<String>()
}
