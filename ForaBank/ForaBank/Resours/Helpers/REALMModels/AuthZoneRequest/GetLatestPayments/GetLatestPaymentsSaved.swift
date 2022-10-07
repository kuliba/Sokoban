//
//  GetLatestPaymentsSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation
import RealmSwift

struct GetLatestPaymentsSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject]) {
        
        NetworkManager<GetLatestPaymentsDecodableModel>.addRequest(.getLatestPayments, param, body) { model, error in
            if error != nil {
                
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let m = model.data else { return }
                    
                    var tempArray = [GetLatestPayments]()
                    
                    m.forEach { b in
                        
                        let a = GetLatestPayments()
                        a.paymentDate = b.paymentDate
                        a.bankName = b.bankName
                        a.bankId = b.bankID
                        a.amount = b.amount
                        a.phoneNumber = b.phoneNumber
                        
                        tempArray.append(a)
                        
                    }
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let b = realm?.objects(GetLatestPayments.self)
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
