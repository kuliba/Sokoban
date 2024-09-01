//
//  PaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentProviderPickerFlowEvent<Latest, PayByInstructions, Payment, Provider, Service, ServicesFailure> {
    
    case dismiss
    case goToPayments
    case initiatePaymentResult(InitiatePaymentResult)
    case loadServices(ServicesResult<Service, ServicesFailure>)
    case payByInstructions(PayByInstructions)
    case select(Select)
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
}

extension PaymentProviderPickerFlowEvent: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable, Service: Equatable, ServicesFailure: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable, Service: Equatable {}
