//
//  CarouselEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 07.10.2024.
//

public final class CarouselEffectHandler {
    
    private let action: (Event) -> Void

    public init(action: @escaping (Event) -> Void) {
        self.action = action
    }
}

public extension CarouselEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .goToMain:
            action(.card(.goToMain))
        case let .openUrl(link):
            action(.card(.openUrl(link)))
        case .cardOrder:
            break
        }
    }
}

public extension CarouselEffectHandler {
    
    typealias Effect = CarouselEffect
    typealias Event = LandingEvent
    typealias Dispatch = (Event) -> Void
}
    
