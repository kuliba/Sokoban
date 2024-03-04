//
//  UtilityPaymentTypes.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.02.2024.
//

import Foundation

#warning("replace with `UtilityPayment` types from module, like `typealias UtilityPaymentState = UtilityPayment.UtilityPaymentState`, etc")

struct UtilityPaymentState: Equatable {
    
}


enum UtilityPaymentEvent: Equatable {}
enum UtilityPaymentEffect: Equatable {}

final class UtilityPaymentReducer {}

extension UtilityPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
    }
}

extension UtilityPaymentReducer {
    
    typealias State = UtilityPaymentState
    typealias Event = UtilityPaymentEvent
    typealias Effect = UtilityPaymentEffect
}

final class UtilityPaymentEffectHandler {}


#warning("mapping in the Composition Route")
extension UtilityPaymentState {
    
    init(_ details: PaymentsTransfersEvent.PaymentStarted.PaymentDetails) {
        
        self.init()
    }
}
