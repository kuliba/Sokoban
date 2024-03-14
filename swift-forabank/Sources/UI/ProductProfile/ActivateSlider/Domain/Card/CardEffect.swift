//
//  CardEffect.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import Foundation

public enum CardEffect: Equatable {
    
    case activate
    case confirmation(DispatchTimeInterval)
    case dismiss(DispatchTimeInterval)
}

