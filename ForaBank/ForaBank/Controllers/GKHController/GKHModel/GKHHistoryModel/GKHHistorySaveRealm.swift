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
        
        /// Общая информация об поставщике услуг
        var additionalList          = GKHHistoryModel()
        var tempAdditionalListArray = [AdditionalListModel]()
        
        NetworkManager<GetLatestServicePaymentsDecodableModel>.addRequest(.getLatestServicePayments, [:], [:]) { model, error in
            
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let additionalListData = model.data else { return }
    
                additionalListData.forEach { list in
                            /// Общая информация об поставщике услуг
                            let a = GKHHistoryModel()
                            a.amount    = list.amount ?? 0
                            a.paymentDate = list.paymentDate
                            a.puref    = list.puref
                            
                            /// Поля для заполнения
                            list.additionalList?.forEach({ parameterList in
                                let p = AdditionalListModel()
                                p.fieldName       = parameterList.fieldName
                                p.fieldValue     = parameterList.fieldValue
                                tempAdditionalListArray.append(p)
                            })
                            additionalList = a
                            tempAdditionalListArray.forEach { i in
                                additionalList.additionalList.append(i)
                            }
                            
                            tempAdditionalListArray.removeAll()
                        }
                        /// Сохраняем в REALM
                        let realm = try? Realm()
                        do {
                            let operators = realm?.objects(GKHHistoryModel.self)
//                            guard (operators != nil) else { return }
                            realm?.beginWrite()
                            realm?.delete(operators!)
                            realm?.add(additionalList)
                            try realm?.commitWrite()
                            print("REALM",realm?.configuration.fileURL?.absoluteString ?? "")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
}

