//
//  PaymentsTransfersState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

typealias PaymentsTransfersState = GenericPaymentsTransfersState<LastPayment, Operator, UtilityService>

typealias GenericPaymentsTransfersState<LastPayment, Operator, Service> = UtilityPayment.PaymentsTransfersState<UtilityDestination<LastPayment, Operator, Service>>
