//
//  MarketShowcaseFlowEffectHandlerMicroServices.swift
//
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public struct MarketShowcaseFlowEffectHandlerMicroServices<Destination, InformerPayload> {
    
    public let orderCard: OrderCard
    
    public let orderSticker: OrderSticker
    
    public init(
        orderCard: @escaping OrderCard,
        orderSticker: @escaping OrderSticker
    ) {
        self.orderCard = orderCard
        self.orderSticker = orderSticker
    }
}

public extension MarketShowcaseFlowEffectHandlerMicroServices {
    
    typealias OrderCard = (@escaping (Destination) -> Void) -> Void
    typealias OrderSticker = (@escaping (Destination) -> Void) -> Void
}
