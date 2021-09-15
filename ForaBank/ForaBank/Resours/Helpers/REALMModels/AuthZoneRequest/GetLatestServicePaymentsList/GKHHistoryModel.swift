//
//  GKHHistoryModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

class GKHHistoryModel: Object {
    
    @objc dynamic var paymentDate: String?
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var puref: String?
    
    var additionalList  = List<AdditionalListModel>()
    
}

