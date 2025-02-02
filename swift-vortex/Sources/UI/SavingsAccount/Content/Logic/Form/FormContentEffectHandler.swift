//
//  FormContentEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Foundation

public final class FormContentEffectHandler<Landing, InformerPayload> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = FormContentEffectHandlerMicroServices<Landing, InformerPayload>
}

public extension FormContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .load:
            microServices.loadLanding() {
                switch $0 {
                    
                case let .failure(backendFailure):
                    switch backendFailure.kind {
                    case let .alert(message):
                        dispatch(.failure(.alert(message)))
                        
                    case let .informer(informerPayload):
                        dispatch(.failure(.informer(informerPayload)))
                    }
                    
                case let .success(landing):
                   dispatch(.loaded(landing))
                }
            }
        }
    }
}

public extension FormContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
}
