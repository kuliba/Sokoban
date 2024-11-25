//
//  RootViewModelFactorySettings.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.10.2024.
//

import Foundation

struct RootViewModelFactorySettings {
    
    let delay: DispatchQueue.SchedulerTimeType.Stride
    let fraudDelay: Double
    let pageSize: Int
    let categoryPickerPlaceholderCount: Int
    let operationPickerPlaceholderCount: Int
}

extension RootViewModelFactorySettings {
    
    static let iFora: Self = .init(
        delay: .milliseconds(100),
        fraudDelay: 120,
        pageSize: 50,
        categoryPickerPlaceholderCount: 6,
        operationPickerPlaceholderCount: 4
    )
}
