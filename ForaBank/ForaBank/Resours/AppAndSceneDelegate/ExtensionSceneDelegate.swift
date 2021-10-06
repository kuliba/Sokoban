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
       
        if AppDelegate.shared.isAuth ?? false {
            
            let realm = try? Realm()
            let timeObject = realm?.objects(GetSessionTimeout.self).first
            let lastActionTimestamp = timeObject?.currentTimeStamp ?? ""
            let maxTimeOut = timeObject?.timeDistance ?? 0
            let currentTimeStamp = Date().localDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            
            guard let date = dateFormatter.date(from: lastActionTimestamp) else { return false }
            let d = date.localDate()
            let withTimeDistance = d.addingTimeInterval(TimeInterval(maxTimeOut))
            let r = withTimeDistance.seconds(from: currentTimeStamp)
            
            if r < 0 {
                let currency = GetSessionTimeout()
                currency.timeDistance = maxTimeOut
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let time = dateFormatter.string(from: date)
                // Сохраняем текущее время
                currency.currentTimeStamp = time
                
                /// Сохраняем в REALM
                let realm = try? Realm()
                do {
                    let b = realm?.objects(GetSessionTimeout.self)
                    realm?.beginWrite()
                    realm?.delete(b!)
                    realm?.add(currency)
                    try realm?.commitWrite()
                    
                } catch {
                    print(error.localizedDescription)
                }
                goVC(.validate, maxTimeOut)
            }
        }
        return false
    }
    
    func goVC(_ mode: ALMode, _ distanceTime: Int) {
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
