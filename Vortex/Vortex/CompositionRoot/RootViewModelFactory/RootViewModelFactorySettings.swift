//
//  RootViewModelFactorySettings.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.10.2024.
//

import Foundation

struct RootViewModelFactorySettings {
    
    let categoryPickerPlaceholderCount: Int
    let batchDelay: DispatchQueue.SchedulerTimeType.Stride
    /// interval to protect calls from being discarded on quick succession
    let delay: DispatchQueue.SchedulerTimeType.Stride
    let fraudDelay: Double
    let observeLast: Int
    let operationPickerPlaceholderCount: Int
    let otpDuration: Int
    let otpLength: Int
    let pageSize: Int
}

extension RootViewModelFactorySettings {
    
    static let prod: Self = .init(
        categoryPickerPlaceholderCount: 6,
        batchDelay: .milliseconds(500),
        delay: .milliseconds(600),
        fraudDelay: 120,
        observeLast: 10,
        operationPickerPlaceholderCount: 4,
        otpDuration: 60,
        otpLength: 6,
        pageSize: 50
    )
}
