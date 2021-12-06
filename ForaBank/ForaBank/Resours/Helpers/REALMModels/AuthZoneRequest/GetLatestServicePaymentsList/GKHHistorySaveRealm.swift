//
//  GKHHistorySaveRealm.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

// MARK: - Save REALM
struct AddHistoryList {
    
    static func add() {
        
        let param = ["isPhonePayments": "false",
                     "isCountriesPayments": "false",
                     "isServicePayments": "true",
                     "isMobilePayments": "false",
                     "isInternetPayments": "false"]
        
        NetworkManager<GetLatestServicePaymentsDecodableModel>.addRequest(.getLatestServicePayments, param, [:]) { model, error in
            
            if let error = error {
                
                print("DEBUG: error", error)
                return
            }
            
            guard let model = model else { return }
            guard let receivedData = model.data else { return }
            
            let receivedPayments = receivedData.map{ GKHHistoryModel(with: $0) }
            
            do {
                
                let realm = try Realm()
                let existingPayments = realm.objects(GKHHistoryModel.self)
                
                // fitst transaction: delete items to inform subscribers in UI
                try realm.write {
                    
                    realm.delete(existingPayments)
                }
                
                // second transaction: add fresh data from server
                try realm.write {
                    
                    realm.add(receivedPayments)
                }
                
            } catch {
                
                print(error.localizedDescription)
            }
        }
    }
}

