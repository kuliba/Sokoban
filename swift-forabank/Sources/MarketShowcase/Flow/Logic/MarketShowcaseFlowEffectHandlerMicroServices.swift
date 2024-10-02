//
//  MarketShowcaseFlowEffectHandlerMicroServices.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public struct MarketShowcaseFlowEffectHandlerMicroServices<Destination, InformerPayload> {
    
    public let orderCard: OrderCard
    public let orderSticker: OrderSticker
    public let showLanding: ShowLanding
    
    public init(
        orderCard: @escaping OrderCard,
        orderSticker: @escaping OrderSticker,
        showLanding: @escaping ShowLanding
    ) {
        self.orderCard = orderCard
        self.orderSticker = orderSticker
        self.showLanding = showLanding
    }
}

public extension MarketShowcaseFlowEffectHandlerMicroServices {
    
    typealias OrderCard = (@escaping (Destination) -> Void) -> Void
    typealias OrderSticker = (@escaping (Destination) -> Void) -> Void
    typealias ShowLanding = (String, @escaping (Destination) -> Void) -> Void
}
