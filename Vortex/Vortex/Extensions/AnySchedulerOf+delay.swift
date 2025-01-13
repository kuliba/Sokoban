//
//  AnySchedulerOf+delay.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.01.2025.
//

import CombineSchedulers
import Foundation

extension AnySchedulerOf<DispatchQueue> {
    
    /// Delays execution of a closure by a specified timeout.
    ///
    /// - Parameters:
    ///   - timeout: The delay duration.
    ///   - action: The closure to execute after the delay.
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: now.advanced(by: timeout), action)
    }
}

typealias Delay = DispatchQueue.SchedulerTimeType.Stride
