//
//  GKHParametersModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

// MARK: - ParameterList
class Parameters: Object {

    @objc dynamic var id: String?
    @objc dynamic var order = 0
    @objc dynamic var title: String?
    @objc dynamic var subTitle: String?
    @objc dynamic var viewType: String?
    @objc dynamic var dataType: String?
    @objc dynamic var type: String?
    @objc dynamic var mask: String?
    @objc dynamic var regExp: String?
    @objc dynamic var maxLength = 0
    @objc dynamic var minLength = 0
    @objc dynamic var rawLength = 0
    
}
