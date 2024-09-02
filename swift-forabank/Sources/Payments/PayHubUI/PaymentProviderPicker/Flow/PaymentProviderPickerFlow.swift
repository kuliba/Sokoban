//
//  PaymentProviderPickerFlow.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import RxViewModel

typealias PaymentProviderPickerFlow<Latest, PayByInstructions, Payment, Provider, Service, ServicesFailure> = RxViewModel<PaymentProviderPickerFlowState<PayByInstructions, Payment, Service, ServicesFailure>, PaymentProviderPickerFlowEvent<Latest, PayByInstructions, Payment, Provider, Service, ServicesFailure>, PaymentProviderPickerFlowEffect<Latest, Provider>>
