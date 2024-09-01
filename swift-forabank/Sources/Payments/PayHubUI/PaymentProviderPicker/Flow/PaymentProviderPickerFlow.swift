//
//  PaymentProviderPickerFlow.swift
//
//
//  Created by Igor Malyarov on 01.09.2024.
//

import PayHub
import RxViewModel

typealias PaymentProviderPickerFlow<Latest, PayByInstructions, Payment, Provider, Service> = RxViewModel<PaymentProviderPickerFlowState<PayByInstructions, Payment, Service>, PaymentProviderPickerFlowEvent<Latest, Payment, PayByInstructions, Provider, Service>, PaymentProviderPickerFlowEffect<Latest, Provider>>
