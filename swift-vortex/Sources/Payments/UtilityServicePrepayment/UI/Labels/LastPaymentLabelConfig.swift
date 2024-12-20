//
//  LastPaymentLabelConfig.swift
//
//
//  Created by Igor Malyarov on 11.05.2024.
//

import SharedConfigs

public struct LastPaymentLabelConfig {
    
    let amount: TextConfig
    let title: TextConfig
    
    public init(
        amount: TextConfig,
        title: TextConfig
    ) {
        self.amount = amount
        self.title = title
    }
}
