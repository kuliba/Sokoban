//
//  MarketShowcaseConfig.swift
//  Vortex
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public struct MarketShowcaseConfig {
    
    let spinnerHeight: CGFloat
}

public extension MarketShowcaseConfig {
    
    static let iVortex: Self = .init(spinnerHeight: 48)
}
