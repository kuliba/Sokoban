//
//  GetProductTemplateListSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.09.2021.
//

import Foundation
import RealmSwift

struct GetProductTemplateListSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject]) {
        
        NetworkManager<GetProductTemplateListDecodableModel>.addRequest(.getProductTemplateList, param, body) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let m = model.data else { return }
                    
                    var tempArray = [GetProductTemplateList]()
                    
                    m.forEach { b in
                        
                        let a = GetProductTemplateList()
                        a.id = b.id ?? 0
                        a.numberMask = b.numberMask
                        a.customName = b.customName
                        a.currency = b.currency
                        a.type = b.type
                        
                        tempArray.append(a)
                        
                    }
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let b = realm?.objects(GetProductTemplateList.self)
                        realm?.beginWrite()
                        realm?.delete(b!)
                        realm?.add(tempArray)
                        try realm?.commitWrite()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
