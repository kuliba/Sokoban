//
//  GetProductTemplateList.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.09.2021.
//

import Foundation
import RealmSwift

//// MARK: - GetProductTemplateList
class GetProductTemplateList: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var numberMask: String?
    @objc dynamic var customName: String?
    @objc dynamic var currency: String?
    @objc dynamic var type: String?
}

