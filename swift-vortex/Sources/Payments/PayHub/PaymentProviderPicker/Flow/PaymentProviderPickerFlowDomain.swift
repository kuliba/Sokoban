//
//  PaymentProviderPickerFlowDomain.swift
//
//
//  Created by Igor Malyarov on 24.09.2024.
//

public enum PaymentProviderPickerFlowDomain<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure> {}

public extension PaymentProviderPickerFlowDomain {
    
    typealias Navigation = PaymentProviderPickerNavigation<DetailPayment, Payment, ServicePicker, ServicesFailure>
    
    typealias State = PaymentProviderPickerFlowState<Navigation>
    typealias Event = PaymentProviderPickerFlowEvent<Navigation, Latest, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
    
    typealias Reducer = PaymentProviderPickerFlowReducer<Navigation, Latest, Provider>
    typealias EffectHandler = PaymentProviderPickerFlowEffectHandler<Navigation, Latest, Provider>
}
