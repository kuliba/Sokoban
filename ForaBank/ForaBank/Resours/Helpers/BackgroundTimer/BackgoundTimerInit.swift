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
        
        //Читаем данные из REALM
        let realm = try? Realm()
        let timeObject = realm?.objects(GetSessionTimeout.self).first
        let lastActionTimestamp = timeObject?.lastActionTimestamp ?? Date().localDate()
        let maxTimeOut = timeObject?.maxTimeOut ?? 0
        let renewSessionTimeStamp = timeObject?.renewSessionTimeStamp ?? Date().localDate()
        let mustCheckTimeOut = timeObject?.mustCheckTimeOut ?? true
        // Получаем и форматируем текущее время
        let currentTimeStamp = Date().localDate()
        // timeOutSecondsRemaining - Расчитываем разницу по времени между последним нажатием или отправкой запроса
        
        let withTimeDistance = lastActionTimestamp.addingTimeInterval(TimeInterval(maxTimeOut))
        let timeOutSecondsRemaining = withTimeDistance.seconds(from: currentTimeStamp)
        // Расчитываем остаток времени в границах между 0.9 и 1.0 от общего времени
        let nowReNewdateSecond = renewSessionTimeStamp.timeIntervalSince1970
        let nowCurrentTimeStampSecond = currentTimeStamp.timeIntervalSince1970
        // 0.9
        let minSessionRenewTimeOutPassed = -(nowReNewdateSecond - nowCurrentTimeStampSecond) > 0.9 * Double(( maxTimeOut))
        // 1.0
        let maxSessionRenewTimeOutNotPassed = -(nowReNewdateSecond - nowCurrentTimeStampSecond) <= Double(( maxTimeOut))
        
        if mustCheckTimeOut {
            // mustCheckTimeOut = true
            if timeOutSecondsRemaining < 0 {
                // Блокируем всплывающее окно
                let realm = try? Realm()
                try? realm?.write {
                    let counter = realm?.objects(GetSessionTimeout.self)
                    counter?.first?.mustCheckTimeOut = false
                    realm?.add(counter!)
                }
                DispatchQueue.main.async {
//                    AppLockerHelper.goVC(.validate)
                }
            } else {
                if minSessionRenewTimeOutPassed  {
                    // Остаток времени в промежутке между 0.9 и 1.0 от общего времени ожидания maxTimeOut
                    // Отправка запроса на сервер об обновлении сессии после удачной авторизации
                    
                    if maxSessionRenewTimeOutNotPassed {
                        let request = GetSessionTimeoutSaved()
                        request.add([:], [:]) {}
                    }
                }
            }
        }
        return
    }
}

