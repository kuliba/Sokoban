//
//  GetNotificationsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import Foundation
import RealmSwift

//// MARK: - GetNotificationsModel
class GetNotificationsSectionModel: Object {
    
    @objc dynamic var date: String?
    var getNotificationsCell = List<GetNotificationsCellModel>()
}

class GetNotificationsCellModel: Object {
    @objc dynamic var date: String?
    @objc dynamic var title: String?
    @objc dynamic var text: String?
    @objc dynamic var type: String?
    @objc dynamic var state: String?
}

extension GetNotificationsSectionModel {
    
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
