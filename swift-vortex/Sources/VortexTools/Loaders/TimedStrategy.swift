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
        
        var hasResult = false
        
        scheduler.delay(for: interval) { [weak self] in
            
            guard let self else { return }
            
            if !hasResult {
                
                hasResult = true
                completion(local())
            }
        }
        
        remote { [weak self] in
            
            guard !hasResult, let self else { return }
            
            hasResult = true
            
            switch $0 {
            case .none:
                completion(local())
                
            case let .some(value):
                completion(value)
            }
        }
    }
}
