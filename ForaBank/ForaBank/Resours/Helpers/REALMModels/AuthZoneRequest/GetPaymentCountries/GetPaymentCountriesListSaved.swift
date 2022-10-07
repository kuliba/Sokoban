//
//  GetPaymentCountriesListSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.09.2021.
//

import Foundation
import RealmSwift

struct GetPaymentCountriesListSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject]) {
        
        NetworkManager<GetPaymentCountriesDecodableModel>.addRequest(.getPaymentCountries, param, body) { model, error in
            if error != nil {
                
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let m = model.data else { return }
                    
                    var tempArray = [GetPaymentCountriesList]()
                    
                    m.forEach { b in
                        
                        let a = GetPaymentCountriesList()
                        a.surName = b.surName
                        a.firstName = b.firstName
                        a.middleName = b.middleName
                        a.shortName = b.shortName
                        a.countryName = b.countryName
                        a.countryCode = b.countryCode
                        a.puref = b.puref
                        a.phoneNumber = b.phoneNumber
                        
                        tempArray.append(a)
                        
                    }
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let b = realm?.objects(GetPaymentCountriesList.self)
                        realm?.beginWrite()
                        realm?.delete(b!)
                        realm?.add(tempArray)
                        try realm?.commitWrite()
                    } catch {
                        
                    }
                }
            }
        }
    }
}
