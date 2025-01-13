//
//  ScheduledThrottleDecorator.swift
//  
//
//  Created by Igor Malyarov on 12.05.2024.
//

import Foundation

public final class ScheduledThrottleDecorator {
    
    private let timeInterval: TimeInterval
    private var lastCallTime: TimeInterval = 0
    private let scheduler: AnySchedulerOfDispatchQueue
    private let lock = NSLock()
    
    public init(
        timeInterval: TimeInterval,
        scheduler: AnySchedulerOfDispatchQueue
    ) {
        self.timeInterval = timeInterval
        self.scheduler = scheduler
    }
}

public extension ScheduledThrottleDecorator {
    
    func callAsFunction(
        block: @escaping () -> Void
    ) {
        scheduler.schedule { [weak self] in
            
            let currentTime = Date().timeIntervalSince1970
            
            guard let self,
                  currentTime - lastCallTime >= timeInterval
            else { return }
            
            self.lock.lock()
            defer { self.lock.unlock() }
            
            lastCallTime = currentTime
            block()
        }
    }
}
