//
//  GetCollateralLandingDomain+Reducer.swift
//
//
//  Created by Valentin Ozerov on 13.01.2025.
//

extension GetCollateralLandingDomain {
    
    public final class Reducer {
        
        public init() {}
        
        public func reduce(_ state: State, _ event: Event) -> (State, Effect?) {
           
            var state = state
            var effect: Effect?
            
            switch event {
            case let .load(landingId):
                guard !state.isLoading else { break }
                        
                state.isLoading = true
                effect = .load(landingId)
                
            case let .loaded(result):
                state.isLoading = false
                state.result = result
            }
            
            return (state, effect)
        }
    }
}
