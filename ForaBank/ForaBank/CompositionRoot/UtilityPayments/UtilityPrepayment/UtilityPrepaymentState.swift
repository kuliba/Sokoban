//
//  UtilityPrepaymentState.swift
//
//
//  Created by Igor Malyarov on 09.05.2024.
//

import UtilityServicePrepaymentDomain

typealias UtilityPrepaymentState = PrepaymentPickerState<UtilityPaymentLastPayment, UtilityPaymentOperator<String>>
