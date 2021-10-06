//
//  AppLockerHelper.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.10.2021.
//

import UIKit
import RealmSwift

struct AppLockerHelper {
    
    static func goVC(_ mode: ALMode, _ distanceTime: Int, _ reNewSessionTimeStamp: String) {
        guard let vc = UIApplication.getTopViewController() else {return}
        
        DispatchQueue.main.async {
            var options = ALOptions()
            options.isSensorsEnabled = UserDefaults().object(forKey: "isSensorsEnabled") as? Bool
            options.onSuccessfulDismiss = { (mode: ALMode?) in
                DispatchQueue.main.async {
                    if mode != nil {
                        let currency = GetSessionTimeout()
                        currency.timeDistance = distanceTime
                        
                        let date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                        let time = dateFormatter.string(from: date)
                        // Сохраняем текущее время
                        currency.currentTimeStamp = time
                        currency.reNewSessionTimeStamp = reNewSessionTimeStamp
                        
                        /// Сохраняем в REALM
                        let realm = try? Realm()
                        do {
                            let b = realm?.objects(GetSessionTimeout.self)
                            realm?.beginWrite()
                            realm?.delete(b!)
                            realm?.add(currency)
                            try realm?.commitWrite()
                            guard let vcLoker = UIApplication.getTopViewController() else {return}
                            vcLoker.navigationController?.popViewController(animated: true)
                        } catch {
                            print(error.localizedDescription)
                        }
                    } else {
                        print("User Cancelled")
                    }
                }
            }
            options.onFailedAttempt = { (mode: ALMode?) in
                print("Failed to \(String(describing: mode))")
            }
            
            AppLocker.present(with: mode, and: options, over: vc)
        }
    }
}
