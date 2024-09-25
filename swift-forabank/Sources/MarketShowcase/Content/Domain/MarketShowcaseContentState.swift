//
//  MarketShowcaseContentState.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public struct MarketShowcaseContentState<Landing> {
    
    public var selection: Selection?
    public var status: MarketShowcaseContentStatus<Landing>

    public init(
        selection: Selection? = nil,
        status: MarketShowcaseContentStatus<Landing>
    ) {
        self.selection = selection
        self.status = status
    }
}

public extension MarketShowcaseContentState {
    
    enum Selection: Equatable {
        
        case landingType(String)
    }
}

extension MarketShowcaseContentState: Equatable where Landing: Equatable {}

public enum MarketShowcaseContentStatus<Landing> {
    
    case inflight
    case loaded(Landing)
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

extension MarketShowcaseContentStatus: Equatable where Landing: Equatable {}
