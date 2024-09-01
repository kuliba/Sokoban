//
//  PaymentProviderPickerFlowEffectHandlerNanoServices.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public struct PaymentProviderPickerFlowEffectHandlerNanoServices<Latest, Payment, PayByInstructions, Provider, Service> {
    
    public let getServiceCategoryList: GetServiceCategoryList
    public let initiatePayment: InitiatePayment
    public let makePayByInstructions: MakePayByInstructions
    
    public init(
        getServiceCategoryList: @escaping GetServiceCategoryList,
        initiatePayment: @escaping InitiatePayment,
        makePayByInstructions: @escaping MakePayByInstructions
    ) {
        self.getServiceCategoryList = getServiceCategoryList
        self.initiatePayment = initiatePayment
        self.makePayByInstructions = makePayByInstructions
    }
}

public extension PaymentProviderPickerFlowEffectHandlerNanoServices {
    
    typealias GetServiceCategoryList = (Provider, @escaping (Result<[Service], Error>) -> Void) -> Void
    
    typealias InitiatePaymentResult = Result<Payment, ServiceFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (InitiatePaymentPayload<Latest, Service>, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakePayByInstructions = (@escaping (PayByInstructions) -> Void) -> Void
}
