//
//  FlowButtonEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public struct FlowButtonEffectHandlerMicroServices<Destination> {
    
    public let makeDestination: MakeDestination
    
    public init(
        makeDestination: @escaping MakeDestination
    ) {
        self.makeDestination = makeDestination
    }
}

public extension FlowButtonEffectHandlerMicroServices {
    
    typealias MakeDestinationCompletion = (Destination) -> Void
    typealias MakeDestination = (@escaping MakeDestinationCompletion) -> Void
}
