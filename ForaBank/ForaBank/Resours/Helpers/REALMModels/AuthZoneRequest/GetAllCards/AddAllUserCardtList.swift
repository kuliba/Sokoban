//
//  AddAllUserCardtList.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.09.2021.
//

import Foundation
import RealmSwift

// MARK: - Save REALM
struct AddAllUserCardtList {
    
    static func add(_ completion: @escaping () -> Void) {
        
        let params = ["isCard": "true", "isAccount": "true", "isDeposit": "true", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, params, [:]) { model, error in
            
            if let error = error {
                
                print("DEBUG: error", error)
                completion()
                return
            }
            
            guard let model = model,
                  let receivedData = model.data else {
                      
                      completion()
                      return
                  }
            
            let receivedCards = receivedData.map{ UserAllCardsModel(with: $0) }
            
            do {
                
                let realm = try Realm()
                let existingCards = realm.objects(UserAllCardsModel.self).sorted(byKeyPath: "id", ascending: true).toArray(ofType: UserAllCardsModel.self)

                guard let changes = existingCards.update(with: receivedCards) else { return }
                
                try realm.write({
                    
                    realm.delete(changes.removals)
                    realm.add(changes.updates, update: .modified)
                    realm.add(changes.additions)
                })
                
                completion()
                
            } catch  {
                
                print(error.localizedDescription)
                completion()
            }
        }
    }
}



