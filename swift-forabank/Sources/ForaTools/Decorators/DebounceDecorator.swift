//
//  DebounceDecorator.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import Foundation

/// A decorator class to debounce function calls, ensuring that they are executed only after a specified delay since the last call.
public final class DebounceDecorator {
    
    private let delay: TimeInterval
    private var lastWorkItem: DispatchWorkItem?
    private let actionQueue: DispatchQueue
    private let synchronizationQueue = DispatchQueue(label: "com.DebounceDecorator.queue")
    
    /// Initialises the DebounceDecorator with a specified delay and action queue.
    /// - Parameters:
    ///   - delay: The time interval to wait before executing the function.
    ///   - actionQueue: The queue on which the debounced function will be executed. Defaults to the main queue.
    public init(
        delay: TimeInterval,
        actionQueue: DispatchQueue = .main
    ) {
        self.delay = delay
        self.actionQueue = actionQueue
    }
}

public extension DebounceDecorator {
    
    /// Calls the provided block, ensuring that it is executed only after the specified delay since the last call.
    /// Uses a weak reference to self to prevent retain cycles.
    /// - Parameter block: The closure to be debounced.
    func debounce(
        block: @escaping () -> Void
    ) {
        synchronizationQueue.async { [weak self] in
            
            self?.scheduleWorkItem(block)
        }
    }
    
    /// Calls the provided block, ensuring that it is executed only after the specified delay since the last call.
    /// Uses a strong reference to self.
    /// - Parameter block: The closure to be debounced.
    func callAsFunction(
        block: @escaping () -> Void
    ) {
        synchronizationQueue.async { self.scheduleWorkItem(block) }
    }
}

private extension DebounceDecorator {
    
    func scheduleWorkItem(
        _ block: @escaping () -> Void
    ) {
        lastWorkItem?.cancel()
        
        let workItem = DispatchWorkItem(block: block)
        lastWorkItem = workItem
        
        actionQueue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
