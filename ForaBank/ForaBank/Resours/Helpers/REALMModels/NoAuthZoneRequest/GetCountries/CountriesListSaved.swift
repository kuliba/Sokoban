//
//  CountriesListSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

struct CountriesListSaved: DownloadQueueProtocol {
    
     func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping () -> ()) {
        
        NetworkManager<GetCountriesDecodebleModel>.addRequest(.getCountries, param, body) { model, error in
            
            if let error = error {
                print("DEBUG: error", error)
                completion()
                return
            }
            
            guard let model = model, let countriesData = model.data else {
                completion()
                return
            }
            
            // check if we actually have data from serever
            guard let countriesListData = countriesData.countriesList, countriesListData.count > 0 else {
                completion()
                return
            }
            
            let updatedCounties = GetCountries(with: countriesData)
            
            do {
                
                let realm = try Realm()
                let existingCountries = realm.objects(GetCountries.self)
                
                // fitst transaction: delete items to inform subscribers in UI
                try realm.write {
                    
                    realm.delete(existingCountries)
                }
                
                // second transaction: add fresh data from server
                try realm.write {
                    
                    realm.add(updatedCounties)
                }
                
            } catch {
                
                print(error.localizedDescription)
                completion()
            }
        }
    }
}

