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
    
    typealias NotifyEvent = PaymentProviderPickerFlowEvent<Destination, Latest, Provider>
    typealias Notify = (NotifyEvent) -> Void
    
    typealias InitiatePaymentCompletion = (Destination) -> Void
    typealias InitiatePayment = (Latest, @escaping Notify, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakeDetailPayment = (@escaping (Destination) -> Void) -> Void
    
    typealias ProcessProvider = (Provider, @escaping Notify, @escaping (Destination) -> Void) -> Void
}
