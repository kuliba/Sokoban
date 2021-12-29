//
//  GetNotificationsModelSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import Foundation
import RealmSwift

struct GetNotificationsModelSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject], completion: @escaping () -> Void) {
        
        NetworkManager<GetNotificationsDecodableModel>.addRequest(.getNotifications, param, body) { model, error in
            
            if let error = error {
                print("DEBUG: error", error)
                completion()
                return
            }
            
            guard let model = model, let notificationsData = model.data else {
                completion()
                return
            }
            
            let a = notificationsData.map{ $0.date?.components(separatedBy: " ").first ?? "" }.uniqued()
            
            let updatedNotifications = notificationsData.map{ GetNotificationsCellModel(value: $0) }
            
            var resultArray = [GetNotificationsModel]()
            
            let getNotificationsModel = GetNotificationsModel()
            a.forEach { value in
                getNotificationsModel.date = value
                updatedNotifications.forEach { getNotificationsSectionModel in
                    if value == getNotificationsSectionModel.date?.components(separatedBy: " ").first ?? "" {
                        getNotificationsModel.getNotificationsEntity.append(getNotificationsSectionModel)
                    }
                }
                resultArray.append(getNotificationsModel)
            }
            
            do {
                
                let realm = try Realm()
                
                let existingNotifications = realm.objects(GetNotificationsModel.self)
                
                // fitst transaction: delete items to inform subscribers in UI
                try realm.write {
                    realm.delete(existingNotifications)
                }
                
                // second transaction: add fresh data from server
                try realm.write {
                    realm.add(resultArray)
                    print("REALM", realm.configuration.fileURL?.absoluteString ?? "" )
                }
                
                completion()
                
            } catch {
                
                print(error.localizedDescription)
                completion()
            }
        }
    }
}

