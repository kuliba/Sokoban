//
//  ContentEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 03.12.2024.
//

public final class ContentEffectHandler<Landing, InformerPayload> {
    
    private let load: Load
    private let landingType: String
    private var oldLanding: Landing? = nil
    
    public init(
        load: @escaping Load,
        landingType: String
    ) {
        self.load = load
        self.landingType = landingType
    }
}

public extension ContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .load:
             
            load({ dispatch(.dismissInformer(self.oldLanding)) }, landingType) { [weak self] in
                switch $0 {
                case let .failure(backendFailure):
                    
                    dispatch(.failure(backendFailure))
                    
                case let .success(landing):
                    self?.oldLanding = landing
                    dispatch(.loaded(landing))
                }
            }
            
        case .dismissInformer:
            dispatch(.dismissInformer(oldLanding))
        }
    }
}

public extension ContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
    
    typealias DismissInformer = () -> Void
    typealias LoadLandingCompletion = (Result<Landing, BackendFailure<InformerPayload>>) -> Void
    typealias Load = (@escaping DismissInformer, String, @escaping LoadLandingCompletion) -> Void
}
