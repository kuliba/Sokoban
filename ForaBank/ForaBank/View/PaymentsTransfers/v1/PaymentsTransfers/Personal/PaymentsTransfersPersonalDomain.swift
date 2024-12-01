//
//  PaymentsTransfersPersonalDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import PayHubUI

typealias PaymentsTransfersPersonalDomain = PayHubUI.PaymentsTransfersPersonalDomain<PaymentsTransfersPersonalSelect, PaymentsTransfersPersonalNavigation>

enum PaymentsTransfersPersonalSelect: Equatable {
    
    case outside(Outside)
    
    enum Outside: Equatable {
        
        case byPhoneTransfer
        case scanQR
        case templates
        case userProfile
        case utilityPayment // service payment
    }
}

enum PaymentsTransfersPersonalNavigation {
    
}
