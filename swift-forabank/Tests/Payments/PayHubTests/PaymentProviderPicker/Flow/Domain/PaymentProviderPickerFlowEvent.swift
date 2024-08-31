//
//  PaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

import ForaTools

enum PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider, Service> {
    
    case initiatePaymentFailure(ServiceFailure)
    case payByInstructions(PayByInstructions)
    case paymentInitiated(Payment)
    case select(Select)
    case services(Services)
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
    
    typealias Services = MultiElementArray<Service>
}

extension PaymentProviderPickerFlowEvent: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable, Service: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable, Service: Equatable {}
