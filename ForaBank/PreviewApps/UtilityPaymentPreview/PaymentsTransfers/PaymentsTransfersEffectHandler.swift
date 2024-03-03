//
//  PaymentsTransfersEffectHandler.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

final class PaymentsTransfersEffectHandler {
    
    private let loadPrePayment: LoadPrePayment
    
    init(loadPrePayment: @escaping LoadPrePayment) {
        self.loadPrePayment = loadPrePayment
    }
}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .loadPrePayment:
            loadPrePayment {
                
                dispatch(.loaded($0))
            }
        }
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias LoadPrePaymentResult = Result<Event.PrePayment, SimpleServiceFailure>
    typealias LoadPrePaymentCompletion = (LoadPrePaymentResult) -> Void
    typealias LoadPrePayment = (@escaping LoadPrePaymentCompletion) -> Void

    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
