//
//  MarketShowcaseState.swift
//  
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import Foundation

public struct MarketShowcaseState: Equatable {
    
    public var alert: FailureAlert?
    public var status: MarketShowcaseStatus?
    
    public init(
        alert: FailureAlert? = nil,
        status: MarketShowcaseStatus? = nil
    ) {
        self.alert = alert
        self.status = status
    }
}


public enum MarketShowcaseStatus: Equatable {
    
    case inflight
    case loaded
    case failure
    
    var isLoading: Bool {
        
        switch self {
        case .inflight:
            return true
        case .loaded, .failure:
            return false
        }
    }
}


public extension MarketShowcaseState {
    
    typealias Event = MarketShowcaseEvent
}

public struct FailureAlert: Equatable, Identifiable {
    
    public let id: UUID

    let message: String
    
    public init(id: UUID = UUID(), message: String) {
        self.id = id
        self.message = message
    }
}
