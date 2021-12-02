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
            if error != nil {
                print("DEBUG: error", error!)
                completion()
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let m = model.data else { return }
                    
                    let currency = GetCurrency()
                    currency.serial = m.serial
                    
                    m.currencyList?.forEach{ b in
                        let a = GetCurrencyList()
                        
                        a.id = b.id
                        a.code = b.code
                        a.cssCode = b.cssCode
                        a.name = b.name
                        a.unicode = b.unicode
                        a.htmlCode = b.htmlCode
                        
                        currency.currencyList.append(a)
                        
                    }
                    
                    /// Сохраняем в REALM
                    do {
                        let realm = try? Realm()
                        let b = realm?.objects(GetCurrency.self)
                        realm?.beginWrite()
                        realm?.delete(b!)
                        realm?.add(currency)
                        try realm?.commitWrite()
                        completion()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
