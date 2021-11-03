//
//  GetSessionTimeout.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.09.2021.
//

import Foundation
import RealmSwift

///MARK: - GetSessionTimeout
class GetSessionTimeout: Object {
    
    @objc dynamic var currentTimeStamp = Date().localDate()
    @objc dynamic var lastActionTimestamp = Date().localDate()
    @objc dynamic var maxTimeOut = StaticDefaultTimeOut.staticDefaultTimeOut
    @objc dynamic var renewSessionTimeStamp = Date().localDate()
    @objc dynamic var mustCheckTimeOut = true
    
    
}
