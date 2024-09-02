//
//  PaymentProviderPickerFlowEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct PaymentProviderPickerFlowEffectHandlerMicroServices<Destination, Latest, Provider> {
    
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
    
    typealias InitiatePaymentCompletion = (Destination) -> Void
    typealias InitiatePayment = (Latest, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakePayByInstructions = (@escaping (Destination) -> Void) -> Void
    
    typealias ProcessProvider = (Provider, @escaping (Destination) -> Void) -> Void
}
