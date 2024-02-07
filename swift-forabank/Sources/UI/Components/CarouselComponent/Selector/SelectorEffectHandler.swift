//
//  SelectorEffectHandler.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public final class SelectorEffectHandler {}

extension SelectorEffectHandler: EffectHandler {
    
    public typealias Dispatch = (SelectorEvent) -> Void
    
    public func handleEffect(
        _ effect: SelectorEffect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}
