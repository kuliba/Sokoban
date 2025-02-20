//
//  RootViewModelFactorySettings.swift
//  Vortex
//
//  Created by Igor Malyarov on 26.10.2024.
//

import Foundation

struct RootViewModelFactorySettings {
    
    let categoryPickerPlaceholderCount: Int
    let batchDelay: DispatchQueue.SchedulerTimeType.Stride
    /// interval to protect calls from being discarded on quick succession
    let delay: DispatchQueue.SchedulerTimeType.Stride
    let informerDelay: DispatchQueue.SchedulerTimeType.Stride
    let fraudDelay: Double
    let observeLast: Int
    let operationPickerPlaceholderCount: Int
    let otpDuration: Int
    let otpLength: Int
    let pageSize: Int
    let splash: SplashSettings
}

extension RootViewModelFactorySettings {
    
    static let prod: Self = .init(
        categoryPickerPlaceholderCount: 6,
        batchDelay: .milliseconds(500),
        delay: .milliseconds(600),
        informerDelay: .seconds(2),
        fraudDelay: 120,
        observeLast: 10,
        operationPickerPlaceholderCount: 4,
        otpDuration: 60,
        otpLength: 6,
        pageSize: 50,
        splash: SplashSettings(phaseOneDuration: .milliseconds(0),
                               phaseTwoDuration: .milliseconds(1200),
                               delay: .milliseconds(300))
    )
}

struct SplashSettings {
    
    let phaseOneDuration: DispatchQueue.SchedulerTimeType.Stride
    let phaseTwoDuration: DispatchQueue.SchedulerTimeType.Stride
    let delay: DispatchQueue.SchedulerTimeType.Stride
}
