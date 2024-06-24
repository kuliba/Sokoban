//
//  InputState.swift
//
//
//  Created by Andryusina Nataly on 24.06.2024.
//

import SwiftUI
import UIPrimitives

public struct InputState: Equatable {
    
    let id: String
    let maxSum: Decimal
    var value: String
    var warning: String?
    
    public init(
        id: String,
        maxSum: Decimal,
        value: String,
        warning: String? = nil
    ) {
        self.id = id
        self.maxSum = maxSum
        self.value = value
        self.warning = warning
    }
}
