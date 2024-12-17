//
//  GetNotificationsModelSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import Foundation
import RealmSwift

struct GetNotificationsModelSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject], _ query: [URLQueryItem], completion: @escaping (String?) -> Void) {
        
        NetworkManager<GetNotificationsDecodableModel>.addRequest(.getNotifications, param, body, query) { model, error in
            
            if error != nil {
                completion(error)
                return
            }
            
            guard let model = model, let notificationsData = model.data else {
                completion(nil)
                return
            }
            guard !(model.data?.isEmpty ?? true) else { return completion("not update") }
            
            let a = notificationsData.map{ $0.date?.components(separatedBy: " ").first ?? "" }.uniqued()
            guard a.count != 0 else { return completion(nil) }
            let updatedNotifications = notificationsData.map{ GetNotificationsCellModel(with: $0) }
            
            var resultArray = [GetNotificationsModel]()
            
            a.forEach { value in
                let getNotificationsModel = GetNotificationsModel()
                getNotificationsModel.date = value
                var tempResultArray = [GetNotificationsModel]()
                updatedNotifications.forEach { getNotificationsSectionModel in
                    if value == getNotificationsSectionModel.date?.components(separatedBy: " ").first ?? "" {
                        getNotificationsModel.getNotificationsEntity.append(getNotificationsSectionModel)
                    }
                }
                tempResultArray.append(getNotificationsModel)
                resultArray += tempResultArray
                
            }
            
            do {
                
                let realm = try Realm()
                
//                let existingNotifications = realm.objects(GetNotificationsModel.self)
                
                // fitst transaction: delete items to inform subscribers in UI
//                try realm.write {
//                    realm.delete(existingNotifications)
//                }
//
                // second transaction: add fresh data from server
                try realm.write {
                    realm.add(resultArray)
                }
                
                completion(nil)
                
            } catch {
                
                
                completion(nil)
            }
        }
    }
}

