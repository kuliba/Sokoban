//
//  LimitSettingsState.swift
//
//
//  Created by Andryusina Nataly on 25.07.2024.
//

import Foundation

struct LimitSettingsState {
    
    var hiddenInfo: Bool
    let limit: Limit
    let currencySymbol: String
    var newValue: Decimal
    
    init(
        hiddenInfo: Bool,
        limit: Limit,
        currencySymbol: String
    ) {
        self.hiddenInfo = hiddenInfo
        self.limit = limit
        self.currencySymbol = currencySymbol
        self.newValue = limit.value
    }
}
