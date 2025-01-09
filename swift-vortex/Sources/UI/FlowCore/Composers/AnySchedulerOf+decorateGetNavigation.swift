//
//  AnySchedulerOf+decorateGetNavigation.swift
//
//
//  Created by Igor Malyarov on 05.01.2025.
//

import CombineSchedulers
import Foundation

extension AnySchedulerOf<DispatchQueue> {
    
    /// Decorates a `GetNavigation` closure with delay handling based on the provided `delayProvider`.
    /// - Parameter delayProvider: A closure that provides a delay for a given navigation.
    /// - Returns: A decorated `GetNavigation` closure that applies the delay before completing.
    public func decorateGetNavigation<Select, Navigation>(
        delayProvider: @escaping (Navigation) -> Delay
    ) -> (
        @escaping FlowDomain<Select, Navigation>.GetNavigation
    ) -> FlowDomain<Select, Navigation>.GetNavigation {
        
        return { originalGetNavigation in
            
            return { select, notify, completion in
                
                originalGetNavigation(select, notify) { navigation in
                    
                    let delay = delayProvider(navigation)
                    
                    guard delay > .zero
                    else { return completion(navigation) }
                    
                    self.delay(for: delay) { completion(navigation) }
                }
            }
        }
    }
    
    public typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: now.advanced(by: timeout), action)
    }
}
