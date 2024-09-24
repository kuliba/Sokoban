//
//  MarketShowcaseEffect.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public enum MarketShowcaseEffect: Equatable {
    
    case load
    case show(Info)
}

public enum Info: Equatable {
    
    case informer
    case alert(DispatchTimeInterval)
}
