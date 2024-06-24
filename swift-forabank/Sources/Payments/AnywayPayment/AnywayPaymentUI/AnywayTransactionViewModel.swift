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

public final class AnywayTransactionViewModel<Amount, Model, DocumentStatus, Response>: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let mapToModel: MapToModel
    private let makeFooter: MakeFooter
    private let reduce: TransactionReduce
    private let handleEffect: HandleEffect
    private let stateSubject = PassthroughSubject<State, Never>()
    
    public init(
        transaction: State.Transaction,
        mapToModel: @escaping MapToModel,
        makeFooter: @escaping MakeFooter,
        reduce: @escaping TransactionReduce,
        handleEffect: @escaping HandleEffect,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        // model mapping needs `self.event(_:),
        // so initially state is initialised empty
        // after all properties are initialised
        // `updating` is called
        self.state = .init(
            models: [:], 
            footer: .continueButton {},
            transaction: transaction
        )
        self.mapToModel = mapToModel
        self.makeFooter = makeFooter
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
        print("===>>>", ObjectIdentifier(self), "AnywayTransactionViewModel: updated state for reduced transaction on event", event, #file, #line)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in self?.event($0) }
        }
    }
}

public extension AnywayTransactionViewModel {
    
    typealias State = CachedModelsTransaction<Amount, Model, DocumentStatus, Response>
    typealias Event = AnywayTransactionEvent<DocumentStatus, Response>
    typealias Effect = AnywayTransactionEffect
    
    enum NotifyEvent: Equatable {
        
        case payment(AnywayPaymentEvent)
        case getVerificationCode
    }
    typealias Notify = (NotifyEvent) -> Void
    typealias MapToModel = (@escaping Notify) -> (AnywayElement) -> Model
    
    enum AmountEvent: Equatable {
        
        case buttonTap
        case edit(Decimal)
    }
    typealias NotifyAmount = (AmountEvent) -> Void
    typealias MakeFooter = (@escaping NotifyAmount) -> (State.Transaction) -> Footer<Amount>
    
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
                
                switch event {
                case .getVerificationCode:
                    self?.event(.verificationCode(.request))
                    
                case let .payment(paymentEvent):
                    self?.event(.payment(paymentEvent))
                }
            },
            makeFooter: makeFooter { [weak self] event in
                
                // TODO: add tests
                print("===>>>", self.map { ObjectIdentifier($0) } ?? "", "makeFooter call", event, #file, #line)
                
                switch event {
                case .buttonTap:
                    self?.event(.continue)
                    
                case let .edit(amount):
                    self?.event(.payment(.widget(.amount(amount))))
                }
            }
        )
    }
}
