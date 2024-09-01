//
//  PaymentProviderPickerFlowEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct PaymentProviderPickerFlowEffectHandlerMicroServices<Latest, PayByInstructions, Payment, Provider, Service> {
    
    public let initiatePayment: InitiatePayment
    public let makePayByInstructions: MakePayByInstructions
    public let processProvider: ProcessProvider
    
    public init(
        initiatePayment: @escaping InitiatePayment,
        makePayByInstructions: @escaping MakePayByInstructions,
        processProvider: @escaping ProcessProvider
    ) {
        self.initiatePayment = initiatePayment
        self.makePayByInstructions = makePayByInstructions
        self.processProvider = processProvider
    }
}

public extension PaymentProviderPickerFlowEffectHandlerMicroServices {
    
    typealias InitiatePaymentResult = Result<Payment, ServiceFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (Latest, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakePayByInstructions = (@escaping (PayByInstructions) -> Void) -> Void
    
    typealias ProcessProvider = (Provider, @escaping (ProcessProviderResult<Payment, Service>) -> Void) -> Void
}
