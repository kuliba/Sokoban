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
        
        //        if AppDelegate.shared.isAuth ?? false {
        
        lazy var realm = try? Realm()
        
        try? realm?.write {

            let counter = realm?.objects(GetSessionTimeout.self)
            counter?.first?.lastActionTimestamp = Date().localDate()
            counter?.first?.currentTimeStamp = Date().localDate()
            realm?.add(counter!)
            
        }
        
        //        let timeObject = realm?.objects(GetSessionTimeout.self).first
        //        var lastActionTimestamp = timeObject?.currentTimeStamp ?? ""
        //        let maxTimeOut = timeObject?.maxTimeOut ?? 0
        //        let reNewSessionTimeStamp = timeObject?.renewSessionTimeStamp ?? ""
        //        let currentTimeStamp = Date().localDate()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        //
        //        var mustCheckTimeOut = timeObject?.mustCheckTimeOut ?? true
        //
        //        if !mustCheckTimeOut {
        //            lastActionTimestamp = dateFormatter.string(from: currentTimeStamp)
        //            let currency = GetSessionTimeout()
        //            currency.maxTimeOut = maxTimeOut
        //
        //            let date = Date()
        //            let dateFormatter = DateFormatter()
        //            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        //            let time = dateFormatter.string(from: date)
        //            // Сохраняем текущее время
        //            currency.currentTimeStamp = time
        //            currency.renewSessionTimeStamp = reNewSessionTimeStamp
        //            currency.mustCheckTimeOut = true
        //            currency.lastActionTimestamp = lastActionTimestamp
        //            /// Сохраняем в REALM
        //            let realm = try? Realm()
        //            do {
        //                let b = realm?.objects(GetSessionTimeout.self)
        //                realm?.beginWrite()
        //                realm?.delete(b!)
        //                realm?.add(currency)
        //                try realm?.commitWrite()
        //
        //            } catch {
        //                print(error.localizedDescription)
        //            }
        
        //        }
        
        //        guard let date = dateFormatter.date(from: lastActionTimestamp) else { return false }
        //        guard let reNewdateSecond = dateFormatter.date(from: reNewSessionTimeStamp) else { return false }
        //        let d = date.localDate()
        //        let r = reNewdateSecond.localDate()
        //        let withTimeDistance = d.addingTimeInterval(TimeInterval(maxTimeOut))
        //        let distance = withTimeDistance.seconds(from: currentTimeStamp)
        //
        //        let nowReNewdateSecond = r.timeIntervalSince1970
        //        let nowCurrentTimeStampSecond = currentTimeStamp.timeIntervalSince1970
        //        let difference = -(nowReNewdateSecond - nowCurrentTimeStampSecond) > 0.9 * Double(( maxTimeOut))
        //        let difference_1 = -(nowReNewdateSecond - nowCurrentTimeStampSecond) <= Double(( maxTimeOut))
        //
        //
        //        if distance < 0 {
        //
        //            let realm = try? Realm()
        //            let timeObject = realm?.objects(GetSessionTimeout.self).first
        //            mustCheckTimeOut = timeObject?.mustCheckTimeOut ?? true
        //
        //            if mustCheckTimeOut {
        //
        //                AppLockerHelper.goVC(.validate, maxTimeOut, reNewSessionTimeStamp)
        //
        //            }
        //
        //            let currency = GetSessionTimeout()
        //            currency.maxTimeOut = maxTimeOut
        //
        //            let date = Date()
        //            let dateFormatter = DateFormatter()
        //            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        //            let time = dateFormatter.string(from: date)
        //            // Сохраняем текущее время
        //            currency.currentTimeStamp = time
        //            currency.renewSessionTimeStamp = reNewSessionTimeStamp
        //            currency.mustCheckTimeOut = false
        //            currency.lastActionTimestamp = lastActionTimestamp
        //
        //            /// Сохраняем в REALM
        //            do {
        //                let b = realm?.objects(GetSessionTimeout.self)
        //                realm?.beginWrite()
        //                realm?.delete(b!)
        //                realm?.add(currency)
        //                try realm?.commitWrite()
        //
        //            } catch {
        //                print(error.localizedDescription)
        //            }
        //
        //        } else if (difference && difference_1) {
        //            // Отправляем фоновый запрос
        //            let request = GetSessionTimeoutSaved()
        //            request.add([:], [:]) {}
        //        }
        //        }
        return false
    }
    
}
