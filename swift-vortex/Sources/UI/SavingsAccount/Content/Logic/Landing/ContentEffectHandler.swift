//
//  ContentEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

public final class ContentEffectHandler<Landing, InformerPayload> {
    
    private let microServices: MicroServices
    private let landingType: String
    
    public init(
        microServices: MicroServices,
        landingType: String
    ) {
        self.microServices = microServices
        self.landingType = landingType
    }
    
    public typealias MicroServices = ContentEffectHandlerMicroServices<Landing, InformerPayload>
}

public extension ContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .load:
            microServices.loadLanding(landingType) {
                switch $0 {
                    
                case let .failure(backendFailure):
                    dispatch(.failure(backendFailure))
                    
                case let .success(landing):
                    dispatch(.loaded(landing))
                }
            }
        }
    }
}

public extension ContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
}
