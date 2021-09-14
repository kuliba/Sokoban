//
//  GKHAdditionalListModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

class AdditionalListModel: Object {
    
    @objc dynamic var fieldName: String?
    @objc dynamic var fieldValue: String?
    
}
