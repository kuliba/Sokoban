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

//MARK: - convenience inits

extension GetCurrency {
    
    convenience init(with data: GetCurrencyListDataClass) {
        
        self.init()
        serial = data.serial
        
        if let currencyListData = data.currencyList {
            
            currencyList.append(objectsIn: currencyListData.map{GetCurrencyList(with: $0) })
        }
    }
}

extension GetCurrencyList {
    
    convenience init(with data: CurrencyList) {
        
        self.init()
        
        id = data.id
        code = data.code
        cssCode = data.cssCode
        name = data.name
        unicode = data.unicode
        htmlCode = data.htmlCode
    }
}
