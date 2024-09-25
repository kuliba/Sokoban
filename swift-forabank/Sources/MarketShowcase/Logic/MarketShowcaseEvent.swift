//
//  MarketShowcaseEvent.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public enum MarketShowcaseEvent: Equatable {
    
    case update
    case loaded
    case failure(FailureKind)
    case goToMain
    case showAlert
}

public enum FailureKind: Equatable {
    
    case timeout
    case error
}
