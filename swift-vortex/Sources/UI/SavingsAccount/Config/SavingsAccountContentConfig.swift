//
//  SavingsAccountContentConfig.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public struct SavingsAccountContentConfig {
    
    let spinnerHeight: CGFloat
}

public extension SavingsAccountContentConfig {
    
    static let prod: Self = .init(spinnerHeight: 48)
}
