//
//  PaymentProviderPickerFlowEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct PaymentProviderPickerFlowEffectHandlerMicroServices<Destination, Latest, Provider> {
    
    public let initiatePayment: InitiatePayment
    public let makeDetailPayment: MakeDetailPayment
    public let processProvider: ProcessProvider
    
    public init(
        initiatePayment: @escaping InitiatePayment,
        makeDetailPayment: @escaping MakeDetailPayment,
        processProvider: @escaping ProcessProvider
    ) {
        self.initiatePayment = initiatePayment
        self.makeDetailPayment = makeDetailPayment
        self.processProvider = processProvider
    }
}

public extension PaymentProviderPickerFlowEffectHandlerMicroServices {
    
    typealias InitiatePaymentCompletion = (Destination) -> Void
    typealias InitiatePayment = (Latest, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakeDetailPayment = (@escaping (Destination) -> Void) -> Void
    
    typealias ProcessProvider = (Provider, @escaping (Destination) -> Void) -> Void
}
