//
//  PaymentProviderPickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentProviderPickerFlowEvent<Destination, Latest, Provider> {
    
    case alert(BackendFailure)
    case destination(Destination)
    case dismiss
    case select(Select)
}

public extension PaymentProviderPickerFlowEvent {
    
    enum Select {
        
        case detailPayment
        case latest(Latest)
        case outside(Outside)
        case provider(Provider)
    }
    
    enum Outside: Equatable {
        
        case back
        case chat
        case main
        case payments
        case qr
    }
}

extension PaymentProviderPickerFlowEvent: Equatable where Destination: Equatable, Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Destination: Equatable, Latest: Equatable, Provider: Equatable {}
