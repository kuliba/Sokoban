//
//  QRFlowButtonEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

struct QRFlowButtonEffectHandlerMicroServices<Destination> {
    
    let makeDestination: MakeDestination
}

extension QRFlowButtonEffectHandlerMicroServices {
    
    typealias MakeDestinationCompletion = (Destination) -> Void
    typealias MakeDestination = (@escaping MakeDestinationCompletion) -> Void
}
