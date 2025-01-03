//
//  AnySchedulerOf+delay.swift
//
//
//  Created by Igor Malyarov on 03.01.2025.
//

import CombineSchedulers
import Foundation

extension AnySchedulerOf<DispatchQueue> {
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: now.advanced(by: timeout), action)
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}
