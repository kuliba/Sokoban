//
//  TimerViewModel.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import Foundation
import Combine

extension ConfirmViewModel {
    
    class TimerViewModel: ObservableObject {
        
        let delay: TimeInterval
        let description: String
        let completeAction: () -> Void
        
        @Published var value: String
        
        @Published var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
        @Published var connectedTimer: Cancellable? = nil
        @Published var needRepeatButton: Bool = false

        var startTime = Date.timeIntervalSinceReferenceDate
        private let formatter: DateComponentsFormatter = .timerViewFormatter
        
        init(
            delay: TimeInterval,
            description: String,
            completeAction: @escaping () -> Void
        ) {
            
            self.delay = delay
            self.description = description
            self.value = ""
            self.completeAction = completeAction

            value = formatter.string(from: delay) ?? "0 :\(delay)"
        }
                
        func updateValue(
            startTime:TimeInterval,
            delay: TimeInterval,
            time: Date
        ) {
            
            let delta = time.timeIntervalSinceReferenceDate - startTime
            let remain = round(delay - delta)

            if remain == 0 {
                
                cancelTimer()
                needRepeatButton = true
                completeAction()
            }
            
            if remain >= 0 {
                
                value = formatter.string(from: remain) ?? "0 :\(remain)"
            }
        }
        
        func instantiateTimer() {
            self.needRepeatButton = false
            self.value = formatter.string(from: delay) ?? "0 :\(delay)"
            self.startTime = Date.timeIntervalSinceReferenceDate
            self.timer = Timer.publish(every: 1, on: .main, in: .common)
            self.connectedTimer = self.timer.connect()
            return
        }
        
        func cancelTimer() {
            self.connectedTimer?.cancel()
            return
        }
                
        func restartTimer() {
            self.needRepeatButton = false
            self.value = formatter.string(from: delay) ?? "0 :\(delay)"
            self.startTime = Date.timeIntervalSinceReferenceDate
            self.cancelTimer()
            self.instantiateTimer()
            return
        }
    }
}

extension DateComponentsFormatter {
    
    public static var timerViewFormatter: DateComponentsFormatter {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
}

extension ConfirmViewModel.TimerViewModel {
    
    static let sample = ConfirmViewModel.TimerViewModel.init(
        delay: 10,
        description: .timerViewDescription,
        completeAction: {
            
            print("completeAction")
        }
    )
}

extension String {
    
    static let timerViewDescription =
            """
            Код отправлен на +7 ... ... 54 15
            Запросить повторно можно через
            """
}
