//
//  AccountInfoPanelEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 04.03.2024.
//

import Foundation

public final class AccountInfoPanelEffectHandler {
    
    public init(){}
}

public extension AccountInfoPanelEffectHandler {
        
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}

public extension AccountInfoPanelEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = AccountInfoPanelEvent
    typealias Effect = AccountInfoPanelEffect
}
