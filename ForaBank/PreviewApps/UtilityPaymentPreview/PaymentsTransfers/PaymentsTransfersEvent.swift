//
//  PaymentsTransfersEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

enum PaymentsTransfersEvent: Equatable {
    
    case openPrePayment
    case loaded(Result<PrePayment, ServiceFailure>)
}

extension PaymentsTransfersEvent {
    
    struct PrePayment: Equatable {}
}
