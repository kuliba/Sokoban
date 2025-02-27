//
//  TopUp.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import Foundation

public struct TopUp: Equatable {
    
    public var isOn: Bool
    public var isShowFooter: Bool

    public init(
        isOn: Bool,
        isShowFooter: Bool = true
    ) {
        self.isOn = isOn
        self.isShowFooter = isShowFooter
    }
}
