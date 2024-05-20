//
//  UtilityPrepaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.05.2024.
//

import UtilityServicePrepaymentDomain
import RxViewModel

typealias UtilityPrepaymentViewModel = RxViewModel<UtilityPrepaymentState, UtilityPrepaymentEvent, UtilityPrepaymentEffect>

typealias UtilityPrepaymentState = PrepaymentPickerState<UtilityPaymentLastPayment, UtilityPaymentOperator>
typealias UtilityPrepaymentEvent = PrepaymentPickerEvent<UtilityPaymentOperator>
typealias UtilityPrepaymentEffect = PrepaymentPickerEffect<String>
