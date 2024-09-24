//
//  PaymentProviderPickerFlow.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import RxViewModel

public typealias PaymentProviderPickerFlow<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure> = RxViewModel<PaymentProviderPickerFlowState<PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure>>, PaymentProviderPickerFlowEvent<PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure>, Latest, Provider>, PaymentProviderPickerFlowEffect<Latest, Provider>>
