//
//  PaymentProviderPickerFlow.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import RxViewModel

typealias PaymentProviderPickerFlow<Latest, PayByInstructions, Payment, Provider, Service, ServicePicker, ServicesFailure> = RxViewModel<PaymentProviderPickerFlowState<PaymentProviderPickerDestination<PayByInstructions, Payment, ServicePicker, ServicesFailure>>, PaymentProviderPickerFlowEvent<PaymentProviderPickerDestination<PayByInstructions, Payment, ServicePicker, ServicesFailure>, Latest, Provider>, PaymentProviderPickerFlowEffect<Latest, Provider>>
