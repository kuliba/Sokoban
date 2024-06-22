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
import PaymentComponents

public final class AnywayTransactionViewModel<Footer: FooterInterface, Model, DocumentStatus, Response>: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let mapToModel: MapToModel
    private let reduce: TransactionReduce
    private let handleEffect: HandleEffect
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        transaction: State.Transaction,
        mapToModel: @escaping MapToModel,
        footer: Footer,
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
            footer: footer,
            transaction: transaction
        )
        self.mapToModel = mapToModel
        self.reduce = reduce
        self.handleEffect = handleEffect
        self.scheduler = scheduler
        
        // Update state with the initial transaction when `self` is avail
        self.state = updating(state, with: transaction)
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
        
        bind(footer)
    }
}

public extension AnywayTransactionViewModel {
    
    func event(_ event: Event) {
        
        let (transaction, effect) = reduce(state.transaction, event)
        let state = updating(state, with: transaction)
#if DEBUG
        print("===>>>", ObjectIdentifier(self), "AnywayTransactionViewModel: updated state for reduced transaction on event", event, #file, #line)
#endif
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in self?.event($0) }
        }
    }
}

public extension AnywayTransactionViewModel {
    
    typealias State = CachedModelsTransaction<Footer, Model, DocumentStatus, Response>
    typealias Event = AnywayTransactionEvent<DocumentStatus, Response>
    typealias Effect = AnywayTransactionEffect
    
    enum NotifyEvent: Equatable {
        
        case payment(AnywayPaymentEvent)
        case getVerificationCode
    }
    typealias Notify = (NotifyEvent) -> Void
    typealias MapToModel = (@escaping Notify) -> (AnywayElement) -> Model
    
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
            }
        )
    }
}

private extension AnywayTransactionViewModel {
    
    func bind(_ footer: Footer) {
        
        // subscribe to footer
        footer.projectionPublisher
            .dropFirst()
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.update(with: $0) }
            .store(in: &cancellables)
        
        // update footer
        let shared = $state.share()
        
        shared
            .map(\.transaction.isValid)
            .removeDuplicates()
            .sink { [weak footer] in footer?.enableButton($0) }
            .store(in: &cancellables)
        
        #warning("add footer switch amount/button")
    }
    
    func update(
        with projection: FooterProjection
    ) {
        if projection.buttonTap != nil {
            event(.continue)
        } else {
            event(.payment(.widget(.amount(projection.amount))))
        }
    }
}
