//
//  DebounceDecorator.swift
//  
//
//  Created by Igor Malyarov on 20.03.2024.
//

import Foundation

public final class DebounceDecorator {
    
    private let delay: TimeInterval
    private var lastWorkItem: DispatchWorkItem?
    private let actionQueue: DispatchQueue
    private let synchronizationQueue = DispatchQueue(label: "com.DebounceDecorator.queue")
    
    public init(
        delay: TimeInterval,
        actionQueue: DispatchQueue = .main
    ) {
        self.delay = delay
        self.actionQueue = actionQueue
    }
}

public extension DebounceDecorator {
    
    func callAsFunction(block: @escaping () -> Void) {
        
        synchronizationQueue.async { [weak self] in
            
            guard let self else { return }
            
            lastWorkItem?.cancel()
            
            let workItem = DispatchWorkItem(block: block)
            lastWorkItem = workItem
            
            actionQueue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
