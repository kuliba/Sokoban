//
//  ServicePaymentFlowReducer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

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
        case let .notify(status):
            reduce(&state, &effect, with: status)
            
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
        with status: AnywayTransactionStatus?
    ) {
        switch status {
        case .none:
            state.modal = nil
            
        case .awaitingPaymentRestartConfirmation:
            state.modal = .alert(.paymentRestartConfirmation)
            
        case .fraudSuspected:
            if let fraud = factory.makeFraud(state) {
                state.modal = .fraud(fraud)
            }
            
        case .inflight:
            break
            
        case let .serverError(errorMessage):
            state.modal = .alert(.serverError(errorMessage))
            
        case let .result(transactionResult):
            reduce(&state, &effect, with: transactionResult)
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with result: AnywayTransactionStatus.TransactionResult
    ) {
        let formattedAmount = factory.getFormattedAmount(state)
        
        switch result {
        case let .failure(terminated):
            switch terminated {
            case let .fraud(fraud):
                state.modal = nil
                effect = .delay(
                    .showResult(.failure(.init(
                        formattedAmount: formattedAmount,
                        hasExpired: fraud == .expired
                    ))),
                    for: .milliseconds(300)
                )
                
                // TODO: the case should have associated string
            case .transactionFailure:
                state.modal = .alert(.terminalError("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже."))
                
                // TODO: the case should have associated string
            case .updatePaymentFailure:
                state.modal = .alert(.serverError("Error"))
            }
            
        case let .success(report):
            state.modal = nil
            effect = .delay(
                .showResult(.success(report)),
                for: .milliseconds(300)
            )
        }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with result: Event.TransactionResult
    ) {
        switch result {
        case let .failure(fraud):
            state.modal = .fullScreenCover(
                .completed(.failure(.init(
                    formattedAmount: fraud.formattedAmount,
                    hasExpired: fraud.hasExpired
                )))
            )
            
        case let .success(report):
            state.modal = .fullScreenCover(
                .completed(.success(report))
            )
        }
    }
}
