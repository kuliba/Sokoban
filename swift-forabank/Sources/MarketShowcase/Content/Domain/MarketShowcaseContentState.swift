//
//  MarketShowcaseContentState.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public struct MarketShowcaseContentState<Landing, InformerPayload> {
    
    public var selection: Selection?
    public var status: MarketShowcaseContentStatus<Landing, InformerPayload>

    public init(
        selection: Selection? = nil,
        status: MarketShowcaseContentStatus<Landing, InformerPayload>
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

extension MarketShowcaseContentState: Equatable where Landing: Equatable, InformerPayload: Equatable {}

public enum MarketShowcaseContentStatus<Landing, InformerPayload> {
    
    case initiate
    case inflight
    case loaded(Landing)
    case failure(Kind)
    
    var isLoading: Bool {
        
        switch self {
        case .inflight:
            return true
        case .initiate, .failure, .loaded:
            return false
        }
    }
    
    public enum Kind {
        case alert(String)
        case informer(InformerPayload)
    }
}

extension MarketShowcaseContentStatus: Equatable where Landing: Equatable, InformerPayload: Equatable {}

extension MarketShowcaseContentStatus.Kind: Equatable where InformerPayload: Equatable {}
