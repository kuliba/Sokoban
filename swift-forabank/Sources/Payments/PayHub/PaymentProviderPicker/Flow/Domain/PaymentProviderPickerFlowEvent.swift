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
    case goToPayments
    case select(Select)
}

public extension PaymentProviderPickerFlowEvent {
    
    enum Select {
        
        case back
        case chat
        case detailPayment
        case latest(Latest)
        case provider(Provider)
        case qr
    }
}

extension PaymentProviderPickerFlowEvent: Equatable where Destination: Equatable, Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Destination: Equatable, Latest: Equatable, Provider: Equatable {}
