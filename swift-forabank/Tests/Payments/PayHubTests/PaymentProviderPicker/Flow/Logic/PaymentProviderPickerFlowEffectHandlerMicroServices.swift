//
//  PaymentProviderPickerFlowEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

import ForaTools

struct PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, Payment, PayByInstructions, Provider, Service> {
    
    let initiatePayment: InitiatePayment
    let makePayByInstructions: MakePayByInstructions
    let processProvider: ProcessProvider
}

extension PaymentProviderPickerFlowEffectHandlerMicroServices {
    
    typealias InitiatePaymentResult = Result<Payment, ServiceFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (Latest, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakePayByInstructions = (@escaping (PayByInstructions) -> Void) -> Void
    
    typealias ProcessProvider = (Provider, @escaping (ProcessProviderResult<Payment, Service>) -> Void) -> Void
}

enum ProcessProviderResult<Payment, Service> {
    
    case initiatePaymentResult(Result<Payment, ServiceFailure>)
    case services(Services)
    case servicesFailure
}

extension ProcessProviderResult {
    
    typealias Services = MultiElementArray<Service>
}

extension ProcessProviderResult: Equatable where Payment: Equatable, Service: Equatable {}
