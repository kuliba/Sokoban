//
//  BanksListSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

struct BanksListSaved: DownloadQueueProtocol {
    
    func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping (DownloadQueue.Result) -> Void) {
        
        NetworkManager<GetFullBankInfoListDecodableModel>.addRequest(.getFullBankInfoList, param, body) { model, error in
            
            if let error = error {
                print("DEBUG: error", error)
                completion(.failed(nil))
                return
            }
            
            guard let model = model, let bankListData = model.data, let serial = model.data?.serial else {
                completion(.failed(nil))
                return
            }
            
            // check if we actually have data from serever
            guard let bankFullInfoList = bankListData.bankFullInfoList, bankFullInfoList.count > 0 else {
                completion(.passed)
                return
            }

            let updatedBankList = GetBankList(with: bankListData)
            
            do {
                
                let realm = try Realm()
                let existingBankList = realm.objects(GetBankList.self)
                
                // fitst transaction: delete items to inform subscribers in UI
                try realm.write {
                    
                    realm.delete(existingBankList)
                }
                
                // second transaction: add fresh data from server
                try realm.write {
                    
                    realm.add(updatedBankList)
                }
                
                completion(.updated(serial))
                
            } catch {

                completion(.failed(error))
            }
        }
    }
}
