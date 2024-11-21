//
//  PaymentsTransfersPersonal.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import PayHubUI

typealias PaymentsTransfersPersonal = PaymentsTransfersPersonalDomain.Binder

typealias PaymentsTransfersPersonalDomain = PayHubUI.PaymentsTransfersPersonalDomain<PaymentsTransfersPersonalSelect, PaymentsTransfersPersonalNavigation>

enum PaymentsTransfersPersonalSelect {
    
    case byPhoneTransfer
    case scanQR
    case templates
    case userProfile
    case utilityPayment // service payment
}

enum PaymentsTransfersPersonalNavigation {
    
}
