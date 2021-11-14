//
//  GetNotificationsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.11.2021.
//

import Foundation
import RealmSwift

//// MARK: - GetNotificationsModel
class GetNotificationsModel: Object {
    
    @objc dynamic var date: String?
    @objc dynamic var title: String?
    @objc dynamic var text: String?
    @objc dynamic var type: String?
    @objc dynamic var state: String?
    
}
