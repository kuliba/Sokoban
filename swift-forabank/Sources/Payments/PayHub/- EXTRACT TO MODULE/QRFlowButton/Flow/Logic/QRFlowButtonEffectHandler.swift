//
//  QRFlowButtonEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public final class QRFlowButtonEffectHandler<Destination> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = QRFlowButtonEffectHandlerMicroServices<Destination>
}

public extension QRFlowButtonEffectHandler {
    
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

public extension QRFlowButtonEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = QRFlowButtonEvent<Destination>
    typealias Effect = QRFlowButtonEffect
}
