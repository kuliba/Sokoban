//
//  PaymentsTransfersPersonalDomain.swift
//  ForaBank
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
    
    case outside(Outside)
    
    enum Outside: Equatable {
        
        case byPhoneTransfer
        case scanQR
        case templates
        case userAccount
        case utilityPayment // service payment
    }
}

enum PaymentsTransfersPersonalNavigation {
    
    case userAccount
}
