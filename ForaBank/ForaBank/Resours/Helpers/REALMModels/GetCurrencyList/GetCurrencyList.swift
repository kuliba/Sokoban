//
//  GetCurrencyList.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetCurrency
class GetCurrency: Object {
    
    @objc dynamic var serial: String?
    
    var currencyList = List<GetCurrencyList>()
}

//// MARK: - GetCurrencyList
class GetCurrencyList: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var code: String?
    @objc dynamic var name: String?
    @objc dynamic var unicode : String?
    @objc dynamic var htmlCode : String?
    @objc dynamic var cssCode : String?
    
}
