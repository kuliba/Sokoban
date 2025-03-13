//
//  GetShowcaseDomain+Reducer.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public final class Reducer<InformerPayload> where InformerPayload: Equatable {
        
        public init() {}
        
        public func reduce(_ state: State<InformerPayload>, _ event: Event<InformerPayload>)
            -> (State<InformerPayload>, Effect?) {
           
            var state = state
            var effect: Effect?
            
            switch event {
            case .load:
                
                if !state.status.isLoading {
                    let oldShowcase = state.status.oldShowcase
                    state.status = .inflight(oldShowcase)
                    effect = .load
                }
                
            case let .loaded(showcase):
                state.status = .loaded(showcase)
                
            case let .failure(failure):
                switch failure {
                case let .alert(message):
                    let oldShowcase = state.status.oldShowcase
                    state.status = .failure(.alert(message), oldShowcase)
                    
                case let .informer(informer):
                    let oldShowcase = state.status.oldShowcase
                    state.status = .failure(.informer(informer), oldShowcase)                    
                }
                
            case .dismissFailure:
                if let showcase = state.status.oldShowcase {
                    
                    state.status = .loaded(showcase)
                }
                
                state.backendFailure = nil
            }
                
            return (state, effect)
        }
    }
}
