//
//  ThrottleDecorator.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import Foundation

/// A decorator class to throttle function calls, ensuring that they are not executed more frequently than a specified delay.
public final class ThrottleDecorator {
    
    private let delay: TimeInterval
    private var lastCallTime: TimeInterval = 0
    private let queue = DispatchQueue(label: "com.ThrottleDecorator.queue")
    
    /// Initialises the ThrottleDecorator with a specified delay.
    /// - Parameter delay: The minimum time interval between allowed function calls.
    public init(delay: TimeInterval) {
        
        self.delay = delay
    }
}

public extension ThrottleDecorator {
    
    /// Calls the provided block, ensuring that it is not executed more frequently than the specified delay.
    /// Uses a weak reference to self to prevent retain cycles.
    /// - Parameter block: The closure to be debounced.
    func throttle(
        block: @escaping () -> Void
    ) {
        queue.sync { [weak self] in self?.execute(block) }
    }
    
    /// Calls the provided block, ensuring that it is not executed more frequently than the specified delay.
    /// Uses a strong reference to self.
    /// - Parameter block: The closure to be throttled.
    func callAsFunction(
        block: @escaping () -> Void
    ) {
        queue.sync { self.execute(block) }
    }
}

private extension ThrottleDecorator {
    
    func execute(
        _ block: @escaping () -> Void
    ) {
        let currentTime = Date().timeIntervalSince1970
        
        guard currentTime - lastCallTime >= delay
        else { return }
        
        lastCallTime = currentTime
        block()
    }
}
