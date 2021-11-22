//
//  GetNotificationsModelSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import Foundation
import RealmSwift

struct GetNotificationsModelSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject], complition: @escaping () -> Void) {
        
        NetworkManager<GetNotificationsDecodableModel>.addRequest(.getNotifications, param, body) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let statusCode = model?.statusCode else { return }
                if statusCode == 0 {
                    
                    guard let model = model else { return }
                    guard let m = model.data else { return }
                    
                    var tempArray = [GetNotificationsSectionModel]()
                    
                    m.forEach { b in
                        let c = GetNotificationsSectionModel()
                        let a = GetNotificationsCellModel()
                        a.date = b.date
                        a.title = b.title
                        a.text = b.text
                        a.type = b.type
                        a.state = b.state
                        
                        c.date = b.date
                        c.getNotificationsCell.append(a)
                        tempArray.append(c)
                        
                    }
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
//                        let b = realm?.objects(GetNotificationsSectionModel.self)
//                        let a = realm?.objects(GetNotificationsCellModel.self)
                        realm?.beginWrite()
//                        realm?.delete(b!)
//                        realm?.delete(a!)
                        realm?.add(tempArray)
                        try realm?.commitWrite()
                        print("REALM", realm?.configuration.fileURL?.absoluteString ?? "")
                        complition()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

