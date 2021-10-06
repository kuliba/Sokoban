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
    
    @objc dynamic var currentTimeStamp = "0"
    @objc dynamic var lastActionTimestamp = "0"
    @objc dynamic var timeDistance = 0
    @objc dynamic var reNewSessionTimeStamp = "0"
    @objc dynamic var mustCheckTimeOut = true
    
}
