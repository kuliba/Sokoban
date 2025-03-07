//
//  TimedStrategy.swift
//
//
//  Created by Nikolay Pochekuev on 21.02.2025.
//

import CombineSchedulers
import Foundation

final public class TimedStrategy<T> {
    
    private let interval: Interval
    private let remote: Remote
    private let local: Local
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        interval: Interval,
        remote: @escaping Remote,
        local: @escaping Local,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.interval = interval
        self.remote = remote
        self.local = local
        self.scheduler = scheduler
    }
    
    public typealias Interval = DispatchQueue.SchedulerTimeType.Stride
    public typealias Remote = (@escaping (T?) -> Void) -> Void
    public typealias Local = () -> T
    
    public func load(
        completion: @escaping (T) -> Void
    ) {
        let lock = DispatchQueue(label: "com.vortex.TimedStrategy.hasResultLock")
        var hasResult = false
        
        scheduler.delay(for: interval) { [weak self] in
            
            guard let self = self else { return }
            
            var localValue: T?
            var shouldComplete = false
            
            lock.sync {
                
                if !hasResult {
                    hasResult = true
                    shouldComplete = true
                    localValue = self.local()
                }
            }
            
            if shouldComplete, let localValue {
                completion(localValue)
            }
        }
        
        remote { [weak self] result in
            
            guard let self = self else { return }
            
            var valueToComplete: T?
            var shouldComplete = false
            
            lock.sync {
                
                if !hasResult {
                    hasResult = true
                    shouldComplete = true
                    valueToComplete = result ?? self.local()
                }
            }
            
            if shouldComplete, let valueToComplete {
                completion(valueToComplete)
            }
        }
    }
}
