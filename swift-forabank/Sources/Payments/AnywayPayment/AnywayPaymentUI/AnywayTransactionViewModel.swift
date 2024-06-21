//
//  AnywayTransactionViewModel.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentDomain
import Combine
import CombineSchedulers
import ForaTools
import Foundation

public final class AnywayTransactionViewModel<AmountViewModel, Model, DocumentStatus, Response>: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let mapToModel: MapToModel
    private let makeAmountViewModel: MakeAmountViewModel
    private let reduce: TransactionReduce
    private let handleEffect: HandleEffect
    private let stateSubject = PassthroughSubject<State, Never>()
    
    public init(
        transaction: State.Transaction,
        mapToModel: @escaping MapToModel,
        makeAmountViewModel: @escaping MakeAmountViewModel,
        reduce: @escaping TransactionReduce,
        handleEffect: @escaping HandleEffect,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        // model mapping needs `self.event(_:),
        // so initially state is initialised empty
        // after all properties are initialised
        // `updating` is called
        self.state = .init(models: [:], transaction: transaction)
        self.mapToModel = mapToModel
        self.makeAmountViewModel = makeAmountViewModel
        self.reduce = reduce
        self.handleEffect = handleEffect
        
        // Update state with the initial transaction when `self` is avail
        self.state = updating(state, with: transaction)
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension AnywayTransactionViewModel {
    
    func event(_ event: Event) {
        
        let (transaction, effect) = reduce(state.transaction, event)
        let state = updating(state, with: transaction)
        
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in self?.event($0) }
        }
    }
}

public extension AnywayTransactionViewModel {
    
    typealias State = CachedModelsTransaction<AmountViewModel, Model, DocumentStatus, Response>
    typealias Event = AnywayTransactionEvent<DocumentStatus, Response>
    typealias Effect = AnywayTransactionEffect
    
    enum NotifyEvent: Equatable {
        
        case payment(AnywayPaymentEvent)
        case getVerificationCode
    }
    typealias Notify = (NotifyEvent) -> Void
    typealias MapToModel = (@escaping Notify) -> (AnywayElement) -> Model

    typealias MakeAmountViewModel = (State.Transaction) -> AmountViewModel

    typealias TransactionReduce = (State.Transaction, Event) -> (State.Transaction, Effect?)
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias TransactionStatus = Status<DocumentStatus, Response>
}

private extension AnywayTransactionViewModel {
    
    func updating(
        _ state: State,
        with transaction: State.Transaction
    ) -> State {
        
        state.updating(
            with: transaction,
            using: mapToModel { [weak self] event in
                
                // TODO: add tests
                switch event{
                case .getVerificationCode:
                    self?.event(.verificationCode(.request))
                    
                case let .payment(paymentEvent):
                    self?.event(.payment(paymentEvent))
                }
            },
            makeAmountViewModel: makeAmountViewModel
        )
    }
}
