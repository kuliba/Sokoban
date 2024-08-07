//
//  AnywayFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 03.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class AnywayFlowModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let factory: Factory
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var cancellables = Set<AnyCancellable>()
    
    init(
        initialState: State,
        factory: Factory,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.state = initialState
        self.factory = factory
        self.scheduler = scheduler
        
        bind(state.content)
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    typealias State = AnywayFlowState
    typealias Event = AnywayFlowEvent
    typealias Effect = AnywayFlowEffect
    typealias Factory = AnywayFlowModelFactory
    
    typealias Content = State.Content
}

extension AnywayFlowModel {
    
    func event(_ event: Event) {
        
        let effect = reduce(&state, event)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

private extension AnywayFlowModel {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        state.isLoading = false
        var effect: Effect?
        
        switch event {
        case .dismissDestination:
            state.status = nil
            
        case .goTo(.main):
            state.status = .outside(.main)
            
        case .goTo(.payments):
            state.status = .outside(.payments)
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading

        case let .notify(status):
            reduce(&state, &effect, with: status)
            
        case let .showResult(result):
            reduce(&state, &effect, with: result)
        }
        
        return nil
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        case let .delay(event, for: interval):
            scheduler.schedule(after: .init(.now() + interval)) {
                
                dispatch(event)
            }
        }
    }
}

private extension AnywayFlowModel {
    
    func bind(_ content: Content) {
        
        state.content.$state
            .dropFirst()
            .map(\.transaction.status)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.notify($0)) }
            .store(in: &cancellables)
    }
}

private extension AnywayFlowModel {
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with status: AnywayTransactionStatus?
    ) {
        switch status {
        case .none:
            state.status = nil
            
        case .awaitingPaymentRestartConfirmation:
            state.status = .alert(.paymentRestartConfirmation)
            
        case .fraudSuspected:
            let transaction = state.content.state.transaction
            if let fraud = factory.makeFraud(transaction) {
                state.status = .fraud(fraud)
            }
            
        case .inflight:
            state.isLoading = true
            
        case let .serverError(errorMessage):
            state.status = .alert(.serverError(errorMessage))
            
        case let .result(transactionResult):
            reduce(&state, &effect, with: transactionResult)
        }
    }
    
    private func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with result: AnywayTransactionStatus.TransactionResult
    ) {
        guard let formattedAmount = factory.getFormattedAmount(state.content.state.transaction)
        else { return }
        
        switch result {
        case let .failure(terminated):
            switch terminated {
            case let .fraud(fraud):
                state.status = nil
                
                effect = .delay(
                    .showResult(.failure(.init(
                        formattedAmount: formattedAmount,
                        hasExpired: fraud == .expired
                    ))),
                    for: .microseconds(300)
                )
                
            case let .transactionFailure(message):
                state.status = .alert(.terminalError(message))
                
            case let .updatePaymentFailure(message):
                state.status = .alert(.serverError(message))
            }
            
        case let .success(report):
            state.status = nil
            
            effect = .delay(
                .showResult(.success(report)),
                for: .microseconds(300)
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
            state.status = .completed(.init(
                formattedAmount: fraud.formattedAmount,
                result: .failure(.init(hasExpired: fraud.hasExpired))
            ))
            
        case let .success(report):
            let transaction = state.content.state.transaction
            state.status = .completed(.init(
                formattedAmount: factory.getFormattedAmount(transaction) ?? "",
                result: .success(report)
            ))
        }
    }
}
