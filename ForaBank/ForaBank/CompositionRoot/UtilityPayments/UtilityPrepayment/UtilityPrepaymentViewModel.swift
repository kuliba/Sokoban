//
//  UtilityPrepaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import UtilityServicePrepaymentDomain
import RxViewModel

typealias UtilityPrepaymentViewModel = RxViewModel<UtilityPrepaymentState, UtilityPrepaymentEvent, UtilityPrepaymentEffect>

typealias UtilityPrepaymentState = PrepaymentPickerState<UtilityPaymentLastPayment, UtilityPaymentOperator<String>>
typealias UtilityPrepaymentEvent = PrepaymentPickerEvent<UtilityPaymentOperator<String>>
typealias UtilityPrepaymentEffect = PrepaymentPickerEffect<String>
