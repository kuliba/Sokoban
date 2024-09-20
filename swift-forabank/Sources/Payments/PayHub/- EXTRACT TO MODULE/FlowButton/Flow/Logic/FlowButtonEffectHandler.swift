//
//  FlowButtonEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public final class FlowButtonEffectHandler<Destination> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = FlowButtonEffectHandlerMicroServices<Destination>
}

public extension FlowButtonEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .processButtonTap:
            microServices.makeDestination { dispatch(.setDestination($0)) }
        }
    }
}

public extension FlowButtonEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FlowButtonEvent<Destination>
    typealias Effect = FlowButtonEffect
}
