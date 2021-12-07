//
//  GetCurrencyListSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.09.2021.
//

import Foundation
import RealmSwift

struct GetCurrencySaved: DownloadQueueProtocol {
    
    func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping () -> ()) {
        
        NetworkManager<GetCurrencyListDecodableModel>.addRequest(.getCurrencyList, param, body) { model, error in
            
            if let error = error {
                print("DEBUG: error", error)
                completion()
                return
            }
            
            guard let model = model, let currencyData = model.data else {
                completion()
                return
            }
            
            // check if we actually have data from serever
            guard let currencyList = currencyData.currencyList, currencyList.count > 0 else {
                completion()
                return
            }
            
            let updatedCurrency = GetCurrency(with: currencyData)
            
            do {
                
                let realm = try Realm()
                let existingCurrency = realm.objects(GetCurrency.self)
                
                // fitst transaction: delete items to inform subscribers in UI
                try realm.write {
                    
                    realm.delete(existingCurrency)
                }
                
                // second transaction: add fresh data from server
                try realm.write {
                    
                    realm.add(updatedCurrency)
                }
                
            } catch {
                
                print(error.localizedDescription)
                completion()
            }
        }
    }
}
