//
//  GetShowcaseDomain+Reducer.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public final class Reducer<InformerPayload> {
        
        public init() {}
        
        public func reduce(_ state: State<InformerPayload>, _ event: Event<InformerPayload>)
            -> (State<InformerPayload>, Effect?) {
           
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
                
            case .dismissFailure:
                state.isLoading = false
                state.result = nil
            }
            
            return (state, effect)
        }
    }
}
