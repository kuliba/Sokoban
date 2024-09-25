//
//  MarketShowcaseFlowEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public final class MarketShowcaseFlowEffectHandler<Destination, InformerPayload> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = MarketShowcaseFlowEffectHandlerMicroServices<Destination, InformerPayload>
}

public extension MarketShowcaseFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            switch select {

            case .orderCard:
                microServices.orderCard { dispatch(.destination($0)) }
                
            case .orderSticker:
                microServices.orderSticker { dispatch(.destination($0)) }
            }
        }
    }
}

public extension MarketShowcaseFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = MarketShowcaseFlowEvent<Destination, InformerPayload>
    typealias Effect = MarketShowcaseFlowEffect
}
