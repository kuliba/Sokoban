//
//  PaymentProviderPickerFlowEffectHandlerNanoServices.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import ForaTools

public struct PaymentProviderPickerFlowEffectHandlerNanoServices<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure> {
    
    public let getServiceCategoryList: GetServiceCategoryList
    public let initiatePayment: InitiatePayment
    public let makeDetailPayment: MakeDetailPayment
    public let makeServicePicker: MakeServicePicker
    public let makeServicesFailure: MakeServicesFailure
    
    public init(
        getServiceCategoryList: @escaping GetServiceCategoryList,
        initiatePayment: @escaping InitiatePayment,
        makeDetailPayment: @escaping MakeDetailPayment,
        makeServicePicker: @escaping MakeServicePicker,
        makeServicesFailure: @escaping MakeServicesFailure
    ) {
        self.getServiceCategoryList = getServiceCategoryList
        self.initiatePayment = initiatePayment
        self.makeDetailPayment = makeDetailPayment
        self.makeServicePicker = makeServicePicker
        self.makeServicesFailure = makeServicesFailure
    }
}

public extension PaymentProviderPickerFlowEffectHandlerNanoServices {
    
    typealias GetServiceCategoryList = (Provider, @escaping (Result<[Service], Error>) -> Void) -> Void
    
    typealias InitiatePaymentResult = Result<Payment, BackendFailure>
    typealias InitiatePaymentCompletion = (InitiatePaymentResult) -> Void
    typealias InitiatePayment = (InitiatePaymentPayload<Latest, Service>, @escaping InitiatePaymentCompletion) -> Void
    
    typealias MakeDetailPayment = (@escaping (DetailPayment) -> Void) -> Void

    typealias MakeServicePicker = (MultiElementArray<Service>, @escaping (ServicePicker) -> Void) -> Void
    
    typealias MakeServicesFailure = (@escaping (ServicesFailure) -> Void) -> Void
}
