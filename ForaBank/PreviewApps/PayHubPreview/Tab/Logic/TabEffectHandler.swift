//
//  TabEffectHandler.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

final class TabEffectHandler {}

extension TabEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

extension TabEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = TabEvent
    typealias Effect = TabEffect
}
