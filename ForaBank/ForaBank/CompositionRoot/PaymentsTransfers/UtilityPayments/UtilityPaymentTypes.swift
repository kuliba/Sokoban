//
//  UtilityPaymentTypes.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.02.2024.
//

import Foundation
import OperatorsListComponents
import UtilityServicePrepaymentDomain

#warning("replace with `UtilityPayment` types from module, like `typealias UtilityPaymentState = UtilityPayment.UtilityPaymentState`, etc")

struct UtilityPaymentState: Equatable {
    
}


enum UtilityPaymentEvent: Equatable {
    
    case addCompany
    case composed(ComposedEvent)
    case payByInstruction
}

extension UtilityPaymentEvent {
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias ComposedEvent = PrepaymentPickerEvent<Operator>
}

enum UtilityPaymentEffect: Equatable {}

final class UtilityPaymentReducer {}

extension UtilityPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        fatalError()
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
    
    init(_ details: PaymentsTransfersEvent.UtilityServicePaymentFlowEvent.PaymentStarted.PaymentDetails) {
        
        self.init()
    }
}
