//
//  GKHOperatorsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.08.2021.
//

import Foundation
import RealmSwift

// MARK: - GKHOperatorsModel
class GKHOperatorsModel: Object {
    
    @objc dynamic var puref: String?
    @objc dynamic var isGroup = false
    @objc dynamic var name: String?
    @objc dynamic var region: String?
    @objc dynamic var parentCode: String?
    @objc dynamic var serial: String?
    
    var logotypeList  = List<LogotypeData>()
    let synonymList   = List<String>()
    var parameterList = List<Parameters>()
    
}

