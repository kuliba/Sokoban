//
//  PaymentProviderPickerFlowDomain.swift
//
//
//  Created by Igor Malyarov on 24.09.2024.
//

public enum PaymentProviderPickerFlowDomain<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure> {}

public extension PaymentProviderPickerFlowDomain {
    
    typealias Destination = PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure>
    
    typealias State = PaymentProviderPickerFlowState<Destination>
    typealias Event = PaymentProviderPickerFlowEvent<Destination, Latest, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
    
    typealias Reducer = PaymentProviderPickerFlowReducer<Destination, Latest, Provider>
    typealias EffectHandler = PaymentProviderPickerFlowEffectHandler<Destination, Latest, Provider>
}
