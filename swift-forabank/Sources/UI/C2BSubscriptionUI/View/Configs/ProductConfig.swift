//
//  ProductConfig.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import UIPrimitives

public struct ProductConfig {
    
    public let balance: TextConfig
    public let name: TextConfig
    public let number: TextConfig
    public let title: TextConfig
    
    public init(
        balance: TextConfig,
        name: TextConfig,
        number: TextConfig,
        title: TextConfig
    ) {
        self.balance = balance
        self.name = name
        self.number = number
        self.title = title
    }
}
