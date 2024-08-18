//
//  QRFlowButtonEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

final class QRFlowButtonEffectHandler<Destination> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = QRFlowButtonEffectHandlerMicroServices<Destination>
}

extension QRFlowButtonEffectHandler {
    
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

extension QRFlowButtonEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = QRFlowButtonEvent<Destination>
    typealias Effect = QRFlowButtonEffect
}
