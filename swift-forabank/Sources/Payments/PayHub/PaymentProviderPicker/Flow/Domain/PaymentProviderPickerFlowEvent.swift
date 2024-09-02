//
//  PaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentProviderPickerFlowEvent<Destination, Latest, Provider> {
    
    case alert(BackendFailure)
    case dismiss
    case goToPayments
    case destination(Destination)
    case select(Select)
}

public extension PaymentProviderPickerFlowEvent {
    
    enum Select {
        
        case back
        case chat
        case latest(Latest)
        case payByInstructions
        case provider(Provider)
        case qr
    }
}

extension PaymentProviderPickerFlowEvent: Equatable where Destination: Equatable, Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Destination: Equatable, Latest: Equatable, Provider: Equatable {}
