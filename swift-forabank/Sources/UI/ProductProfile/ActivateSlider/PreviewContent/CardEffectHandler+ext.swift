//
//  CardEffectHandler+ext.swift
//
//
//  Created by Andryusina Nataly on 22.02.2024.
//

import Foundation

public extension CardEffectHandler {
    
    static let activateSuccess = CardEffectHandler(
        activate: { _, completion in
            completion(.success)
        }
    )
    
    static let activateFailure = CardEffectHandler(
        activate: { payload, completion in
            completion(.serverError("Error"))
        }
    )
}
