//
//  MarketShowcaseContentEffectHandler.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public final class MarketShowcaseContentEffectHandler<Landing> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = MarketShowcaseContentEffectHandlerMicroServices<Landing>
}

public extension MarketShowcaseContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        case .load:
            microServices.loadLanding {
                switch $0 {
                    
                case .failure:
                    dispatch(.loadFailure)
                    
                case let .success(landing):
                    dispatch(.loaded(landing))
                }
            }
        }
    }
}

public extension MarketShowcaseContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = MarketShowcaseContentEvent<Landing>
    typealias Effect = MarketShowcaseContentEffect
}
