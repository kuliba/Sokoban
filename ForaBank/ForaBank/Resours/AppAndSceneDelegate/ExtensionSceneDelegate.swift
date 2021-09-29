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
        print("Tapped window", "Касание экрану")
        if AppDelegate.shared.isAuth ?? false {
        
        let realm = try? Realm()
        let timeObject = realm?.objects(GetSessionTimeout.self).first
        let startTime = timeObject?.currentTimeStamp ?? ""
        var  distanceTime = timeObject?.timeDistance ?? 0
        // distanceTime = 20
        let currentTime = Date().localDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        guard let date = dateFormatter.date(from: startTime) else { fatalError() }
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
                        vcLoker.dismiss(animated: true)
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
            
            AppLocker.rootViewController(with: mode, and: options, window: self.window)
        }
    }
    
    
}


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}


extension UIApplication {
    /// Определение текущего контроллера
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension Date {
    func localDate() -> Date {
      //  let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return Date()}

        return localDate
    }
}
