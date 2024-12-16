//
//  FlowEffectHandlerMicroServices.swift
//
//
//  Created by Andryusina Nataly on 04.12.2024.
//

public struct FlowEffectHandlerMicroServices<Destination, InformerPayload> {
    
    public let orderAccount: OrderAccount
    
    public init(
        orderAccount: @escaping OrderAccount
    ) {
        self.orderAccount = orderAccount
    }
}

public extension FlowEffectHandlerMicroServices {
    
    typealias OrderAccount = (@escaping (Destination) -> Void) -> Void
}
