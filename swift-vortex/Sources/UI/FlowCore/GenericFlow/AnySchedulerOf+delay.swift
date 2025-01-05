//
//  AnySchedulerOf+delay.swift
//
//
//  Created by Igor Malyarov on 05.01.2025.
//

import CombineSchedulers
import Foundation

extension AnySchedulerOf<DispatchQueue> {
    
    public typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: now.advanced(by: timeout), action)
    }
}
