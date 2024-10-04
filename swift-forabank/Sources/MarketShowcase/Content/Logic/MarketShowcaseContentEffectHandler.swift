//
//  MarketShowcaseContentEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public final class MarketShowcaseContentEffectHandler<Landing, InformerPayload> {
    
    private let microServices: MicroServices
    private let landingType: String
    
    public init(
        microServices: MicroServices,
        landingType: String
    ) {
        self.microServices = microServices
        self.landingType = landingType
    }
    
    public typealias MicroServices = MarketShowcaseContentEffectHandlerMicroServices<Landing, InformerPayload>
}

public extension MarketShowcaseContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .load:
            microServices.loadLanding(landingType) {
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

public extension MarketShowcaseContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = MarketShowcaseContentEvent<Landing, InformerPayload>
    typealias Effect = MarketShowcaseContentEffect
}
