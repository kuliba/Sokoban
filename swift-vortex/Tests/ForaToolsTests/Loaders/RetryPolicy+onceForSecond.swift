//
//  RetryPolicy+onceForSecond.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import ForaTools
import Foundation

extension RetryPolicy {
    
    static let onceForSecond: Self = .init(
        maxRetries: 1,
        strategy: .equal(interval: .seconds(1))
    )
}

