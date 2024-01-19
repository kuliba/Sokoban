//
//  RealTimer.swift
//  
//
//  Created by Igor Malyarov on 18.01.2024.
//

import Combine
import Foundation

class RealTimer: TimerProtocol {
    
    private var timer: AnyCancellable?
    
    func start(
        every interval: TimeInterval,
        onRun: @escaping () -> Void
    ) {
        timer = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { _ in onRun() })
    }
    
    func stop() {
        
        timer?.cancel()
        timer = nil
    }
}
