//
//  ExtensionAppDelegate.swift
//  ForaBank
//
//  Created by Константин Савялов on 28.09.2021.
//

import UIKit
import RealmSwift

extension SceneDelegate: UIGestureRecognizerDelegate {
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        lazy var realm = try? Realm()
        
        try? realm?.write {

            let counter = realm?.objects(GetSessionTimeout.self)
            counter?.first?.lastActionTimestamp = Date().localDate()
            counter?.first?.currentTimeStamp = Date().localDate()
            realm?.add(counter!)
            
        }
        
        return false
    }
    
}
