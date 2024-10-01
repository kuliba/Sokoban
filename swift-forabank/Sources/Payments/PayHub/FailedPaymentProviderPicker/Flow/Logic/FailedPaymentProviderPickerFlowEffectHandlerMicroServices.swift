//
//  FailedPaymentProviderPickerFlowEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

public struct FailedPaymentProviderPickerFlowEffectHandlerMicroServices<Destination> {
    
    public let makeDestination: MakeDestination
    
    public init(makeDestination: @escaping MakeDestination) {
        
        self.makeDestination = makeDestination
    }
}

public extension FailedPaymentProviderPickerFlowEffectHandlerMicroServices {
    
    typealias MakeDestination = (@escaping (Destination) -> Void) -> Void
}
