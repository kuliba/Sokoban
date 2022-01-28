//
//  GKHAddOperatorsList.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

// MARK: - Save REALM
struct AddOperatorsList: DownloadQueueProtocol {

    func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping (DownloadQueue.Result) -> Void) {
        
        NetworkManager<GetAnywayOperatorsListDecodableModel>.addRequest(.getAnywayOperatorsList, param, body) { model, error in
            
            if let error = error {
                print("DEBUG: error", error)
                completion(.failed(nil))
                return
            }
            
            guard let model = model, let operatorsData = model.data, let serial = model.data?.serial else {
                completion(.failed(nil))
                return
            }
            
            // check if we actually have data from serever
            guard let operatorGroupList = operatorsData.operatorGroupList, operatorGroupList.count > 0 else {
                completion(.passed)
                return
            }
            
            let operatorCodes = [GlobalModule.UTILITIES_CODE, GlobalModule.INTERNET_TV_CODE, GlobalModule.PAYMENT_TRANSPORT]
            let parameterTypes = ["INPUT"]
            let updatedOperators = GKHOperatorsModel.childOperators(with: operatorGroupList, operatorCodes: operatorCodes, parameterTypes: parameterTypes)
            
            do {
                
                let realm = try Realm()
                let existingOperators = realm.objects(GKHOperatorsModel.self)
                
                // fitst transaction: delete items to inform subscribers in UI
                try realm.write {
                    
                    realm.delete(existingOperators)
                }
                
                // second transaction: add fresh data from server
                try realm.write {
                    
                    realm.add(updatedOperators)
                }
                
                completion(.updated(serial))
                
            } catch {

                completion(.failed(error))
            }
        }
    }
}
