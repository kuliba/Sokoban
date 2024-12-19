//
//  FailedPaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 23.09.2024.
//

public enum FailedPaymentProviderPickerFlowEvent<Destination> {
    
    case destination(Destination)
    case resetDestination
    case select(Selection)
}

extension FailedPaymentProviderPickerFlowEvent: Equatable where Destination: Equatable {}

public extension FailedPaymentProviderPickerFlowEvent {
    
    enum Selection: Equatable {
        
        case detailPay
    }
}
