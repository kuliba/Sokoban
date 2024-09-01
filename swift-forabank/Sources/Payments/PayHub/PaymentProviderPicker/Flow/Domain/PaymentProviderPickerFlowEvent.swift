//
//  PaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

import ForaTools

public enum PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider, Service> {
    
    case initiatePaymentResult(InitiatePaymentResult)
    case payByInstructions(PayByInstructions)
    case select(Select)
    case loadServices(Services?)
}

public extension PaymentProviderPickerFlowEvent {
    
    typealias InitiatePaymentResult = Result<Payment, ServiceFailure>

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
