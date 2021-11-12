//
//  AppLockerHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.10.2021.
//

import UIKit
import RealmSwift

struct AppLockerHelper {
    
    static func goVC(_ mode: ALMode) {
    print("TIMER")
        let regisration = UserDefaults.standard.object(forKey: "UserIsRegister") as? Bool
        if regisration == true {
            
            guard let topVc = UIApplication.getTopViewController() else {return}
            DispatchQueue.main.async {
                
                let locker: AppLocker = AppLocker.loadFromStoryboard()
                locker.mode = mode
                locker.modalPresentationStyle = .fullScreen
                topVc.present(locker, animated: true, completion: nil)
            }
        }
    }
}


//DispatchQueue.main.async {
//    if mode != nil {
//        let realm = try? Realm()
//        try? realm?.write {
//            let counter = realm?.objects(GetSessionTimeout.self)
//            counter?.first?.mustCheckTimeOut = true
//            realm?.add(counter!)
//        }
//        guard let vc_1 = UIApplication.getTopViewController() else {return}
//        vc_1.dismiss(animated: true, completion: nil)
//    } else {
//        print("User Cancelled")
//    }
//}
