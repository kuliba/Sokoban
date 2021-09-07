//
//  CountriesListSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

struct CountriesListSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject]) {
        
        NetworkManager<GetCountriesDecodebleModel>.addRequest(.getCountries, param, body) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let countries = model.data else { return }
                    
                    let countriesList = GetCountries()
                    countriesList.serial = countries.serial
                    
                    countries.countriesList?.forEach{ country in
                        let model = GetCountriesList()
                        model.code = country.code
                        model.contactCode = country.contactCode
                        model.name = country.name
                        model.md5hash = country.md5Hash
                        model.svgImage = country.svgImage
//                        model.sendC = country.sendCurr
                        country.paymentSystemCodeList?.forEach{ list in
                            model.paymentSystemIdList.append(list)
                        }
                        countriesList.countriesList.append(model)
                    }
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let c = realm?.objects(GetCountries.self)
                        realm?.beginWrite()
                        realm?.delete(c!)
                        realm?.add(countriesList)
                        try realm?.commitWrite()
                        print(realm?.configuration.fileURL?.absoluteString ?? "")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

