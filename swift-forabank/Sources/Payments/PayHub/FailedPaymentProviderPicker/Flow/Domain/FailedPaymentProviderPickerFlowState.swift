//
//  FailedPaymentProviderPickerFlowState.swift
//  
//
//  Created by Igor Malyarov on 23.09.2024.
//

public struct FailedPaymentProviderPickerFlowState<Destination> {
    
    public var destination: Destination?
    
    public init(destination: Destination? = nil) {
     
        self.destination = destination
    }
}

extension FailedPaymentProviderPickerFlowState: Equatable where Destination: Equatable {}
