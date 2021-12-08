//
//  GetPaymentSystemSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.09.2021.
//

import Foundation
import RealmSwift

struct GetPaymentSystemSaved: DownloadQueueProtocol {
    
    func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping (DownloadQueue.Result) -> Void) {
        
        NetworkManager<GetPaymentSystemListDecodableModel>.addRequest(.getPaymentSystemList, param, body) { model, error in
            
            if let error = error {
                print("DEBUG: error", error)
                completion(.failed(nil))
                return
            }
            
            guard let model = model, let paymentSystemData = model.data, let serial = model.data?.serial else {
                completion(.failed(nil))
                return
            }
            
            // check if we actually have data from serever
            guard let paymentSystemDataList = paymentSystemData.paymentSystemList, paymentSystemDataList.count > 0 else {
                completion(.passed)
                return
            }
            
            let updatedPaymentSystemList = GetPaymentSystemList(with: paymentSystemData)
            
            do {
                
                let realm = try Realm()
                let existingPaymentSystemList = realm.objects(GetPaymentSystemList.self)
                
                // fitst transaction: delete items to inform subscribers in UI
                try realm.write {
                    
                    realm.delete(existingPaymentSystemList)
                }
                
                // second transaction: add fresh data from server
                try realm.write {
                    
                    realm.add(updatedPaymentSystemList)
                }
                
                completion(.updated(serial))
                
            } catch {
                
                completion(.failed(error))
            }
        }
    }
}
