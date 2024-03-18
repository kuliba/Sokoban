//
//  CardEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import Foundation

public final class CardEffectHandler {
    
    private let activate: Activate
    
    public init(
        activate: @escaping Activate
    ) {
        self.activate = activate
    }
}

public extension CardEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .activate:
            activate(dispatch)
            
        case let .dismiss(timeInterval):
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                
                dispatch(.dismissActivate)
            }
        case let .confirmation(timeInterval):
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
                
                dispatch(.activateCard)
            }
        }
    }
}

public extension CardEffectHandler {
    
    typealias ActivateResult = Result<Void, Error> // TODO: activateResult
    typealias ActivateCompletion = (ActivateResult) -> Void
    typealias Activate = (@escaping ActivateCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CardEvent
    typealias Effect = CardEffect
}

private extension CardEffectHandler {
    
    func activate(
        _ dispatch: @escaping Dispatch
    ) {
        activate { result in
            
            switch result {
            case .failure:
                dispatch(.activateCardResponse(.connectivityError))
                
            case .success(()):
                dispatch(.activateCardResponse(.success))
            }
        }
    }
}


