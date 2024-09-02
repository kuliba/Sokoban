//
//  PaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentProviderPickerFlowEvent<Latest, PayByInstructions, Payment, Provider, ServicePicker, ServicesFailure> {
    
    case dismiss
    case goToPayments
    case initiatePaymentResult(InitiatePaymentResult)
    case loadServices(ServicesResult<ServicePicker, ServicesFailure>)
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

extension PaymentProviderPickerFlowEvent: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable, ServicePicker: Equatable, ServicesFailure: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Latest: Equatable, Payment: Equatable, PayByInstructions: Equatable, Provider: Equatable, ServicePicker: Equatable {}
