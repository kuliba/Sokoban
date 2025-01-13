//
//  BannersFlowReducer.swift
//
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public final class BannersFlowReducer {
    
    public init() {}
}

public extension BannersFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        }
        
        return (state, effect)
    }
}

public extension BannersFlowReducer {
    
    typealias State = BannersFlowState
    typealias Event = BannersFlowEvent
    typealias Effect = BannersFlowEffect
}

public struct BannersFlowState: Equatable {
    
    public init() {}
}

public enum BannersFlowEvent: Equatable {}

public enum BannersFlowEffect: Equatable {}
