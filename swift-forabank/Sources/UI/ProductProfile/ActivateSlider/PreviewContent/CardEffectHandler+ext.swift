//
//  CardEffectHandler+ext.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import Foundation

public extension CardEffectHandler {
    
    static let activateSuccess = CardEffectHandler(
        activate: { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                completion(.success(()))
            })
        }
    )
    
    static let activateFailure = CardEffectHandler(
        activate: { completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                completion(.failure(ActivateFailure()))
            })
        }
    )

    struct ActivateFailure: Error {}
}
