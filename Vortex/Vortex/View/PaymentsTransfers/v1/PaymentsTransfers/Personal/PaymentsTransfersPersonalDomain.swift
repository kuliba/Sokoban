//
//  PaymentsTransfersPersonalDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import PayHubUI

typealias PaymentsTransfersPersonalDomain = PayHubUI.PaymentsTransfersPersonalDomain<PaymentsTransfersPersonalSelect, PaymentsTransfersPersonalNavigation>

extension PaymentsTransfersPersonalDomain {
    
    typealias Select = PaymentsTransfersPersonalSelect
    typealias Navigation = PaymentsTransfersPersonalNavigation
}

enum PaymentsTransfersPersonalSelect: Equatable {
    
    case byPhoneTransfer
    case main
    case scanQR
    case standardPayment(ServiceCategory.CategoryType)
    case templates
    case userAccount
}

typealias PaymentsTransfersPersonalNavigation = PaymentsTransfersPersonalSelect
