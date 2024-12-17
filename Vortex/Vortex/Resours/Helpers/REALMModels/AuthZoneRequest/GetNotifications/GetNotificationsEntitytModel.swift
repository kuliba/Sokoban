//
//  GetNotificationsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import Foundation
import RealmSwift

/// MARK : - GetNotificationsModel

class GetNotificationsModel: Object {
    
    @objc dynamic var date: String?
    var getNotificationsEntity = List<GetNotificationsCellModel>()
}

/// MARK : - GetNotificationsCellModel
class GetNotificationsCellModel: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var date: String?
    @objc dynamic var title: String?
    @objc dynamic var text: String?
    @objc dynamic var type: String?
    @objc dynamic var state: String?
    
    private func idGeneration(_ date: String) -> String {
        var id = ""
        let a = date.replacingOccurrences(of: " ", with: "")
        let b = a.replacingOccurrences(of: ":", with: "")
        id = String(b.replacingOccurrences(of: ".", with: "").dropFirst(8))
        
        return id
    }
    
    convenience init(with data: GetNotifications?) {
       self.init()
       self.date = data?.date
       self.title = data?.title
       self.text = data?.text
       self.type = data?.type
       self.state = data?.state
        self.id = idGeneration(data?.date ?? "")
    }    
}

