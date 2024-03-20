//
//  ThrottleDecorator.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import Foundation

public final class ThrottleDecorator {
    
    private let delay: TimeInterval
    private var lastCallTime: TimeInterval = 0
    private let queue = DispatchQueue(label: "com.ThrottleDecorator.queue")
    
    public init(delay: TimeInterval) {
        
        self.delay = delay
    }
}

public extension ThrottleDecorator {
    
    func callAsFunction(
        block: @escaping () -> Void
    ) {
        queue.sync { [weak self] in
            
            guard let self else { return }
            
            let currentTime = Date().timeIntervalSince1970
            
            guard currentTime - lastCallTime >= delay else { return }
            
            lastCallTime = currentTime
            
            block()
        }
    }
}
