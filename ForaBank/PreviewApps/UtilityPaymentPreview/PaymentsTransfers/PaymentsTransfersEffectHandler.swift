//
//  PaymentsTransfersEffectHandler.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import UtilityPayment

final class PaymentsTransfersEffectHandler {
    
    private let loadPrePayment: LoadPrePayment
    private let loadServices: LoadServices
    private let startPayment: StartPayment
    
    init(
        loadPrePayment: @escaping LoadPrePayment,
        loadServices: @escaping LoadServices,
        startPayment: @escaping StartPayment
    ) {
        self.loadPrePayment = loadPrePayment
        self.loadServices = loadServices
        self.startPayment = startPayment
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
            
        case let .loadServices(for: `operator`):
            loadServices(`operator`) {
                
                dispatch(.loadedServices($0, for: `operator`))
            }
            
        case let .startPayment(payload):
            startPayment(payload) {
                
                dispatch(.startPaymentResponse($0))
            }
        }
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias LoadPrePaymentResult = Result<Event.PrePayment, SimpleServiceFailure>
    typealias LoadPrePaymentCompletion = (LoadPrePaymentResult) -> Void
    typealias LoadPrePayment = (@escaping LoadPrePaymentCompletion) -> Void
    
    typealias LoadServicesPayload = Operator
    typealias LoadServicesCompletion = (Event.LoadServicesResponse) -> Void
    typealias LoadServices = (LoadServicesPayload, @escaping LoadServicesCompletion) -> Void
    
    typealias StartPaymentPayload = Effect.StartPaymentPayload
    typealias StartPaymentCompletion = (Event.StartPaymentResponse) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void

    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}
