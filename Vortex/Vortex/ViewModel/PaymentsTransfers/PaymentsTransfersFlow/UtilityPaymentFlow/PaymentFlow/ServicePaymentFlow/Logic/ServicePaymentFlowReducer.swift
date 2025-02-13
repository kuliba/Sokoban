//
//  ServicePaymentFlowReducer.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentDomain

final class ServicePaymentFlowReducer {
    
    private let factory: Factory
    
    init(factory: Factory) {
        
        self.factory = factory
    }
    
    typealias Factory = ServicePaymentFlowReducerFactory
}

extension ServicePaymentFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .terminate:
            state = .terminated
            
        case let .notify(projection):
            reduce(&state, &effect, with: projection)
            
        case let .showResult(result):
            reduce(&state, &effect, with: result)
        }
        
        return (state, effect)
    }
}

extension ServicePaymentFlowReducer {
    
    typealias State = ServicePaymentFlowState
    typealias Event = ServicePaymentFlowEvent
    typealias Effect = ServicePaymentFlowEffect
}

private extension ServicePaymentFlowReducer {
    
    // TODO: same logic as in PaymentsTransfersFlowReducer.reduce(_:_:with:) - remove duplication
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with projection: Event.TransactionProjection
    ) {
        switch projection.status {
        case .none:
            state = .none
            
        case .awaitingPaymentRestartConfirmation:
            state = .alert(.paymentRestartConfirmation)
            
        case .fraudSuspected:
            if let fraud = factory.makeFraudNoticePayload(projection.context) {
                state = .fraud(fraud)
            }
            
        case .inflight:
            break
            
        case let .serverError(errorMessage):
            state = .alert(.serverError(errorMessage))
            
        case let .result(transactionResult):
            reduce(&state, &effect, with: projection.context, and: transactionResult)
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with context: AnywayPaymentContext,
        and result: AnywayTransactionStatus.TransactionResult
    ) {
        let formattedAmount = factory.getFormattedAmount(context)
        
        switch result {
        case let .failure(terminated):
            switch terminated {
            case let .fraud(fraud):
                state = .none
                effect = .delay(
                    .showResult(.init(
                        formattedAmount: formattedAmount,
                        merchantIcon: context.outline.payload.icon,
                        result: .failure(.init(hasExpired: fraud == .expired)), 
                        templateID: context.outline.payload.templateID
                    )),
                    for: .milliseconds(300)
                )
                
            case let .transactionFailure(message):
                state = .alert(.terminalError(message))
                
            case let .updatePaymentFailure(message):
                state = .alert(.serverError(message))
            }
            
        case let .success(report):
            state = .none
            effect = .delay(
                .showResult(.init(
                    formattedAmount: formattedAmount,
                    merchantIcon: context.outline.payload.icon,
                    result: .success(report),
                    templateID: context.outline.payload.templateID
                )),
                for: .milliseconds(300)
            )
        }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with completed: Event.Completed
    ) {
        switch completed.result {
        case let .failure(fraud):
            state = .fullScreenCover(.init(
                formattedAmount: completed.formattedAmount,
                merchantIcon: completed.merchantIcon,
                result: .failure(.init(hasExpired: fraud.hasExpired)),
                templateID: completed.templateID
            ))
            
        case let .success(report):
            state = .fullScreenCover(.init(
                formattedAmount: completed.formattedAmount,
                merchantIcon: completed.merchantIcon,
                result: .success(report),
                templateID: completed.templateID
            ))
        }
    }
}
