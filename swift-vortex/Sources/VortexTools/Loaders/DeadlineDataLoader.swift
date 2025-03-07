//
//  DeadlineDataLoader.swift
//
//
//  Created by Igor Malyarov on 07.03.2025.
//

import CombineSchedulers
import Foundation

/// Loads data using an asynchronous loader within a specified time limit.
/// Falls back to synchronous loading if the asynchronous loader fails or exceeds the deadline.
/// Late asynchronous results (after the deadline) are ignored.
final public class DeadlineDataLoader<T> {
    
    private let interval: Interval
    private let asyncLoader: AsyncLoader
    private let syncLoader: SyncLoader
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        interval: Interval,
        asyncLoader: @escaping AsyncLoader,
        syncLoader: @escaping SyncLoader,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.interval = interval
        self.asyncLoader = asyncLoader
        self.syncLoader = syncLoader
        self.scheduler = scheduler
    }
    
    public typealias Interval = DispatchQueue.SchedulerTimeType.Stride
    public typealias AsyncLoader = (@escaping (T?) -> Void) -> Void
    public typealias SyncLoader = () -> T
    
    public func load(
        completion: @escaping (T) -> Void
    ) {
        let lock = DispatchQueue(label: "com.vortex.DeadlineDataLoader.hasResultLock")
        var hasResult = false
        
        scheduler.delay(for: interval) { [weak self] in
            
            guard let self = self else { return }
            
            var syncValue: T?
            var shouldComplete = false
            
            lock.sync {
                
                if !hasResult {
                    hasResult = true
                    shouldComplete = true
                    syncValue = self.syncLoader()
                }
            }
            
            if shouldComplete, let syncValue {
                completion(syncValue)
            }
        }
        
        asyncLoader { [weak self] result in
            
            guard let self = self else { return }
            
            var valueToComplete: T?
            var shouldComplete = false
            
            lock.sync {
                
                if !hasResult {
                    hasResult = true
                    shouldComplete = true
                    valueToComplete = result ?? self.syncLoader()
                }
            }
            
            if shouldComplete, let valueToComplete {
                completion(valueToComplete)
            }
        }
    }
}
