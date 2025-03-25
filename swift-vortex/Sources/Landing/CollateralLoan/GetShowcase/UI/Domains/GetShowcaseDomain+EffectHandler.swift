//
//  GetShowcaseDomain+EffectHandler.swift
//
//
//  Created by Valentin Ozerov on 26.12.2024.
//

extension GetShowcaseDomain {
    
    public final class EffectHandler<InformerPayload> where InformerPayload: Equatable {
        
        let load: Load
        
        public init(
            load: @escaping Load
        ) {
            self.load = load
        }

        public func handleEffect(_ effect: Effect, dispatch: @escaping Dispatch) {
            
            switch effect {
            case .load:
                load {
                    switch $0 {
                    case let .failure(backendFailure):
                        switch backendFailure.kind {
                        case let .alert(message):
                            dispatch(.failure(.alert(message)))
                            
                        case let .informer(informerPayload):
                            dispatch(.failure(.informer(informerPayload)))
                        }
                        
                    case let .success(showcase):
                       dispatch(.loaded(showcase))
                    }

                }
            }
        }

        public typealias Dispatch = (Event<InformerPayload>) -> Void
        public typealias Load = (@escaping Completion) -> Void
        public typealias Completion = (Result<InformerPayload>) -> Void
    }
}
