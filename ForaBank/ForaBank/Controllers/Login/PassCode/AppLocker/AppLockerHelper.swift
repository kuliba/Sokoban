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
        
        guard let vc = UIApplication.getTopViewController() else {return}
        DispatchQueue.main.async {
            var options = ALOptions()
            options.isSensorsEnabled = UserDefaults().object(forKey: "isSensorsEnabled") as? Bool
            options.onSuccessfulDismiss = { (mode: ALMode?, _) in
                DispatchQueue.main.async {
                    if mode != nil {
                        let realm = try? Realm()
                        try? realm?.write {
                            let counter = realm?.objects(GetSessionTimeout.self)
                            counter?.first?.mustCheckTimeOut = true
                            realm?.add(counter!)
                        }
                        guard let vc_1 = UIApplication.getTopViewController() else {return}
                        vc_1.dismiss(animated: true, completion: nil)
                    } else {
                        print("User Cancelled")
                    }
                }
            }
            
            options.onFailedAttempt = { (mode: ALMode?) in
                print("Failed to \(String(describing: mode))")
            }
//            AppLocker.present(with: mode, and: options, over: vc)
        }
    }
}
