//
//  GetShowcaseDomain+Reducer.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public final class Reducer {
        
        public init() {}
        
        public func reduce(_ state: State, _ event: Event) -> (State, Effect?) {
           
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
