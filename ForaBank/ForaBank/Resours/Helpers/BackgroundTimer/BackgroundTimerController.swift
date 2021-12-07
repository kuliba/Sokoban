//
//  BackgroundTimerController.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.10.2021.
//

import Foundation

final class BackgroundTimer {
    
    // Ежесекундная проверка истечения времени обновления и вызов метода обновления сети
    let timer = TimerRepeat(timeInterval: 1)
    let time = TimerTimeInit()
    func repeatTimer() {
        timer.eventHandler = { [weak self] in
            self?.time.timeResult()
        }
        timer.resume()
    }
    
}

