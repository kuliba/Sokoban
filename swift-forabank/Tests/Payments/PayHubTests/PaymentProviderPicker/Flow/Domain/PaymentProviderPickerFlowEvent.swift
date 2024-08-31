//
//  PaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

enum PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider> {
    
    case initiatePaymentFailure(ServiceFailure)
    case payByInstructions(PayByInstructions)
    case paymentInitiated(Payment)
    case select(Select)
}

extension PaymentProviderPickerFlowEvent {
    
    enum Select {
        
        case back
        case chat
        case latest(Latest)
        case payByInstructions
        case provider(Provider)
        case qr
    }
}

extension PaymentProviderPickerFlowEvent: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable {}
