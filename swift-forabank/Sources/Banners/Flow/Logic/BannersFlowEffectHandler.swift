//
//  BannersFlowEffectHandler.swift
//  
//
//  Created by Andryusina Nataly on 09.09.2024.
//

public final class BannersFlowEffectHandler {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = BannersFlowEffectHandlerMicroServices
}

public extension BannersFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        }
    }
}

public extension BannersFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = BannersFlowEvent
    typealias Effect = BannersFlowEffect
}

public struct BannersFlowEffectHandlerMicroServices {
    
    public init() {}
}
