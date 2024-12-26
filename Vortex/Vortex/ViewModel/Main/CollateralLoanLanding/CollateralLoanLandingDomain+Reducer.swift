//
//  CollateralLoanLandingDomain+Reducer.swift
//  Vortex
//
//  Created by Valentin Ozerov on 24.12.2024.
//

extension CollateralLoanLandingDomain {
    
    final class Reducer {
        
        func reduce(_ state: State, _ event: Event) -> (State, Effect?) {
           
            var state = state
            var effect: Effect?
            
            switch event {
            case .load:
                guard !state.isLoading else { break }
                        
                state.isLoading = true
                effect = .load
                
            case let .loaded(result):
                state.isLoading = false
                state.result = result
                
            case let .productTap(productType):
                // TODO: Need to realize
                print(productType)
                break
            }
            
            return (state, effect)
        }
    }
}
