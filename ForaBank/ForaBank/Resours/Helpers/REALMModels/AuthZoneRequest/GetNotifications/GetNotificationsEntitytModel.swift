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

/// MARK : - GetNotificationsEntitytModel
class GetNotificationsEntitytModel: Object {
    
    @objc dynamic var date: String?
    var getNotificationsCell = List<GetNotificationsCellModel>()
}

/// MARK : - GetNotificationsCellModel
class GetNotificationsCellModel: Object {
    
    @objc dynamic var date: String?
    @objc dynamic var title: String?
    @objc dynamic var text: String?
    @objc dynamic var type: String?
    @objc dynamic var state: String?
    
}

/// MARK : - extension GetNotificationsEntitytModel
extension GetNotificationsEntitytModel {

    convenience init(with data: GetNotifications) {

        self.init()

        let cellModel = GetNotificationsCellModel()
        cellModel.date = data.date
        cellModel.title = data.title
        cellModel.text = data.text
        cellModel.type = data.type
        cellModel.state = data.state

        date = data.date
        getNotificationsCell.append(cellModel)
    }
}
