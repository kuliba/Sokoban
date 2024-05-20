//
//  ScheduledDebounceDecorator.swift
//
//
//  Created by Igor Malyarov on 12.05.2024.
//

import Combine
import Foundation

public final class ScheduledDebounceDecorator {
    
    private let delay: TimeInterval
    private var lastWorkItem: DispatchWorkItem?
    private let scheduler: AnySchedulerOfDispatchQueue
    private let lock = NSLock()
    
    public init(
        delay: TimeInterval,
        scheduler: AnySchedulerOfDispatchQueue
    ) {
        self.delay = delay
        self.scheduler = scheduler
    }
}

public extension ScheduledDebounceDecorator {
    
    func callAsFunction(
        block: @escaping () -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        lastWorkItem?.cancel()
        
        let workItem = DispatchWorkItem(block: block)
        lastWorkItem = workItem
        
        let scheduleTime = scheduler.now.advanced(by: AnySchedulerOfDispatchQueue.SchedulerTimeType.Stride(floatLiteral: delay))
        scheduler.schedule(
            after: scheduleTime,
            // Adding some tolerance can optimise the behaviour of the scheduler
            tolerance: .milliseconds(10),
            options: nil,
            workItem.perform
        )
    }
}
