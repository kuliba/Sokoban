//
//  RootViewModelFactorySettings.swift
//  ForaBank
//
//  Created by Igor Malyarov on 26.10.2024.
//

struct RootViewModelFactorySettings {
    
    let fraudDelay: Double
    let pageSize: Int
    let categoryPickerPlaceholderCount: Int
    let operationPickerPlaceholderCount: Int
}

extension RootViewModelFactorySettings {
    
    static let iFora: Self = .init(
        fraudDelay: 120,
        pageSize: 50,
        categoryPickerPlaceholderCount: 6,
        operationPickerPlaceholderCount: 4
    )
}
