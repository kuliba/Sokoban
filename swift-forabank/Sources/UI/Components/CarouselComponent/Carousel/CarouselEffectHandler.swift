//
//  CarouselEffectHandler.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel

public final class CarouselEffectHandler {}

extension CarouselEffectHandler: EffectHandler {
    
    public typealias Dispatch = (CarouselEvent) -> Void
    
    public func handleEffect(
        _ effect: CarouselEffect,
        _ dispatch: @escaping Dispatch
    ) {
        
    }
}
