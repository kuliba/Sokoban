//
//  BackgoundTimerInit.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.10.2021.
//

import Foundation
import RealmSwift

// Таймер установки общего времени в секундах

class TimerTimeInit {
    
    var timerModel = GetSessionTimeout.self
    
    lazy var realm = try? Realm()
    
    func timeResult() {
        
        //        if AppDelegate.shared.isAuth ?? false {
        
        let realm = try? Realm()
        let timeObject = realm?.objects(GetSessionTimeout.self).first
        var lastActionTimestamp = timeObject?.currentTimeStamp ?? ""
        let maxTimeOut = timeObject?.timeDistance ?? 0
        let reNewSessionTimeStamp = timeObject?.reNewSessionTimeStamp ?? ""
        let currentTimeStamp = Date().localDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        let mustCheckTimeOut = timeObject?.mustCheckTimeOut ?? true
        
        guard let date = dateFormatter.date(from: lastActionTimestamp) else { return }
        guard let reNewdateSecond = dateFormatter.date(from: reNewSessionTimeStamp) else { return }
        let d = date.localDate()
        let r = reNewdateSecond.localDate()
        let withTimeDistance = d.addingTimeInterval(TimeInterval(maxTimeOut))
        let distance = withTimeDistance.seconds(from: currentTimeStamp)
        
        let nowReNewdateSecond = r.timeIntervalSince1970
        let nowCurrentTimeStampSecond = currentTimeStamp.timeIntervalSince1970
        let difference = -(nowReNewdateSecond - nowCurrentTimeStampSecond) > 0.9 * Double(( maxTimeOut))
        let difference_1 = -(nowReNewdateSecond - nowCurrentTimeStampSecond) <= Double(( maxTimeOut))
        
        
        if distance < 0 {
            
            if mustCheckTimeOut {
                
                AppLockerHelper.goVC(.validate, maxTimeOut, reNewSessionTimeStamp)
                
            }
            
            let currency = GetSessionTimeout()
            currency.timeDistance = maxTimeOut
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let time = dateFormatter.string(from: date)
            // Сохраняем текущее время
            currency.currentTimeStamp = time
            currency.reNewSessionTimeStamp = reNewSessionTimeStamp
            currency.mustCheckTimeOut = false
            currency.lastActionTimestamp = lastActionTimestamp
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
            
            
        } else if (difference && difference_1) {
            // Отправляем фоновый запрос
            let request = GetSessionTimeoutSaved()
            request.add([:], [:]) {}
        }
        //        }
        
    }
}

