//
//  QRFlowButtonEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public struct QRFlowButtonEffectHandlerMicroServices<Destination> {
    
    public let makeDestination: MakeDestination
    
    public init(
        makeDestination: @escaping MakeDestination
    ) {
        self.makeDestination = makeDestination
    }
}

public extension QRFlowButtonEffectHandlerMicroServices {
    
    typealias MakeDestinationCompletion = (Destination) -> Void
    typealias MakeDestination = (@escaping MakeDestinationCompletion) -> Void
}
