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
        let phoneNumber: PhoneDomain.Phone
        let completeAction: () -> Void
        let resendRequest: () -> Void

        @Published var value: String
        
        @Published var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .default)
        @Published var connectedTimer: Cancellable? = nil
        @Published var needRepeatButton: Bool = false

        var startTime = Date.timeIntervalSinceReferenceDate
        private let formatter: DateComponentsFormatter = .timerViewFormatter
        
        init(
            delay: TimeInterval,
            phoneNumber: PhoneDomain.Phone,
            completeAction: @escaping () -> Void,
            resendRequest: @escaping () -> Void
        ) {
            
            self.delay = delay
            self.phoneNumber = {
                if phoneNumber.contains(".") { return phoneNumber }
                return .init(phoneNumber.rawValue.formattedPhoneNumber())
            }()
            self.value = ""
            self.completeAction = completeAction
            self.resendRequest = resendRequest

            value = formatter.string(from: delay) ?? "0 :\(delay)"
            self.instantiateTimer()
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
            self.timer = Timer.publish(every: 1, on: .main, in: .default)
            self.connectedTimer = self.timer.connect()
            return
        }
        
        func cancelTimer() {
            self.connectedTimer?.cancel()
            return
        }
                
        func restartTimer() {
            self.needRepeatButton = false
            resendRequest()
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
        delay: 60,
        phoneNumber: .testNumber,
        completeAction: {
            
            print("completeAction")
        }, 
        resendRequest: {
            print("resenRequest")
        }
    )
}

extension PhoneDomain.Phone {
    
    static let testNumber: Self = "71234567890"
}

private extension String {
    
    func separate(
        every stride: Int = 2,
        with separator: Character = " "
    ) -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
    
    func formattedPhoneNumber() -> String {
        let cleanNumber = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        return "+" + cleanNumber.prefix(1) + " ... ... " + String(self.suffix(4)).separate(every:2, with: " ")
    }
}
