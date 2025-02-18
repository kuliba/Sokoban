//
//  FormContentEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Foundation

public final class FormContentEffectHandler<Landing, InformerPayload> {
    
    private let loadLanding: LoadLanding
    private let timeInterval: DispatchTimeInterval

    public init(
        loadLanding: @escaping LoadLanding,
        timeInterval: DispatchTimeInterval = .seconds(2)
    ) {
        self.loadLanding = loadLanding
        self.timeInterval = timeInterval
    }
}

public extension FormContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .load:
            loadLanding() {
                switch $0 {
                    
                case let .failure(backendFailure):
                    dispatch(.failure(backendFailure))
                    
                case let .success(landing):
                    dispatch(.loaded(landing))
                }
            }
            
        case .hideInformer:
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                dispatch(.hideInformer)
            }
        }
    }
}

public extension FormContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SavingsAccountContentEvent<Landing, InformerPayload>
    typealias Effect = SavingsAccountContentEffect
    
    typealias LoadLandingCompletion = (Result<Landing, BackendFailure<InformerPayload>>) -> Void
    typealias LoadLanding = (@escaping LoadLandingCompletion) -> Void
}
