//
//  PaymentProviderPickerFlowEffectHandlerNanoServices.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public struct PaymentProviderPickerFlowEffectHandlerNanoServices<Latest, PayByInstructions, Payment, Provider, Service, ServicePicker, ServicesFailure> {
    
    public let getServiceCategoryList: GetServiceCategoryList
    public let initiatePayment: InitiatePayment
    public let makePayByInstructions: MakePayByInstructions
    public let makeServicePicker: MakeServicePicker
    public let makeServicesFailure: MakeServicesFailure
    
    public init(
        getServiceCategoryList: @escaping GetServiceCategoryList,
        initiatePayment: @escaping InitiatePayment,
        makePayByInstructions: @escaping MakePayByInstructions,
        makeServicePicker: @escaping MakeServicePicker,
        makeServicesFailure: @escaping MakeServicesFailure
    ) {
        self.getServiceCategoryList = getServiceCategoryList
        self.initiatePayment = initiatePayment
        self.makePayByInstructions = makePayByInstructions
        self.makeServicePicker = makeServicePicker
        self.makeServicesFailure = makeServicesFailure
    }
}

public extension PaymentProviderPickerFlowEffectHandlerNanoServices {
    
    typealias GetServiceCategoryList = (Provider, @escaping (Result<[Service], Error>) -> Void) -> Void
    
    typealias InitiatePaymentResult = Result<Payment, BackendFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (InitiatePaymentPayload<Latest, Service>, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakePayByInstructions = (@escaping (PayByInstructions) -> Void) -> Void

    typealias MakeServicePicker = (MultiElementArray<Service>, @escaping (ServicePicker) -> Void) -> Void
    
    typealias MakeServicesFailure = (@escaping (ServicesFailure) -> Void) -> Void
}
