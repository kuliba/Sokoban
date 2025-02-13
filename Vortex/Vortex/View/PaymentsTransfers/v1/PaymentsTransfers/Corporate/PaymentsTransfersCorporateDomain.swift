//
//  PaymentsTransfersCorporateDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import PayHubUI

typealias PaymentsTransfersCorporateDomain = PayHubUI.PaymentsTransfersCorporateDomain<PaymentsTransfersCorporateSelect, PaymentsTransfersCorporateNavigation>

extension PaymentsTransfersCorporateDomain {
    
    typealias Select = PaymentsTransfersCorporateSelect
    typealias Navigation = PaymentsTransfersCorporateNavigation
}

enum PaymentsTransfersCorporateSelect {

    case main
    case userAccount
}

enum PaymentsTransfersCorporateNavigation: Equatable {
    
    case main
    case userAccount
}
