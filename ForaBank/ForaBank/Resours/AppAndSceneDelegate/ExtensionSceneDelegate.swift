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
//        print("Tapped window", "Касание экрану")
        if AppDelegate.shared.isAuth ?? false {
        
        let realm = try? Realm()
        let timeObject = realm?.objects(GetSessionTimeout.self).first
        let startTime = timeObject?.currentTimeStamp ?? ""
        let distanceTime = timeObject?.timeDistance ?? 0
        let currentTime = Date().localDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        guard let date = dateFormatter.date(from: startTime) else { return false }
        let d = date.localDate()
        let withTimeDistance = d.addingTimeInterval(TimeInterval(distanceTime))
        let r = withTimeDistance.seconds(from: currentTime)
        
        if r < 0 {
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

                } catch {
                    print(error.localizedDescription)
                }
            goVC(.validate, distanceTime)
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

import UIKit

extension SceneDelegate {
    
    
    
}

