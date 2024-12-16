//
//  TimerSpy.swift
//  
//
//  Created by Igor Malyarov on 21.01.2024.
//

import Foundation
import OTPInputComponent

final class TimerSpy: TimerProtocol {
    
    private let duration: Int
    private var completions = [Completion]()
    private(set) var messages = [Message]()
    
    init(duration: Int) {
        
        self.duration = duration
    }
    
    var callCount: Int { messages.count }
    
    func start(
        every interval: TimeInterval,
        onRun completion: @escaping Completion
    ) {
        completions = .init(repeating: completion, count: duration/Int(interval))
        messages.append(.start)
    }
    
    func stop() {
        
        messages.append(.stop)
    }
    
    func tick() {
        completions.remove(at: 0)()
    }
    
    typealias Completion = () -> Void
    
    enum Message: Equatable {
        
        case start, stop
    }
}
