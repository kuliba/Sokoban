//
//  CarouselEffectHandler.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import RxViewModel
import Foundation

public final class CarouselEffectHandler {
    
    public init() { }
}

extension CarouselEffectHandler: EffectHandler {
    
    public typealias Dispatch = (CarouselEvent) -> Void
    
    public func handleEffect(
        _ effect: CarouselEffect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .scrollTo(let id, let timeInterval):
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: {
                
                dispatch(.scrolledTo(id))
            })
        }
    }
}
