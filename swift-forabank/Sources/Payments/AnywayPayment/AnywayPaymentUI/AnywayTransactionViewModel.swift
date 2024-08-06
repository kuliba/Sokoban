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

public final class AnywayTransactionViewModel<Footer, Model, DocumentStatus, Response>: ObservableObject
where Footer: FooterInterface & Receiver<Decimal>,
      Model: Receiver,
      Model.Message == AnywayMessage,
      DocumentStatus: Equatable,
      Response: Equatable {
    
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
            transaction: transaction,
            isAwaitingConfirmation: transaction.status == .awaitingPaymentRestartConfirmation
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
        
        if transaction != state.transaction {
            
            let state = updating(state, with: transaction)
            stateSubject.send(state)            
            sendOTPWarning(state)
        }
        
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
    
    typealias TransactionStatus = AnywayStatus<DocumentStatus, Response>
}

private extension AnywayTransactionViewModel {
    
    func sendOTPWarning(
        _ state: State
    ) {
        state.otpWarning.map {
            
            state.models[.widgetID(.otp)]?.receive(.otpWarning($0))
        }
    }
    
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
    
    /// Does not use `.removeDuplicates()` in the pipelines due to different sources of change.
    /// For example, button status `active`/`inactive` is set depending on transaction, but `tapped` is set reacting to UI event. Using `.removeDuplicates()` would drop changes.
    func bind(_ footer: Footer) {
        
        // subscribe to footer state projection
        /// - Note: looks like this pipeline needs `dropFirst` but if `dropFirst` is added the button does not gets active after first submit
        footer.projectionPublisher
            .receive(on: scheduler)
            .print("===== footer.projectionPublisher")
            .sink { [weak self] in self?.update(with: $0) }
            .store(in: &cancellables)
    }
    
    func update(
        with projection: Projection
    ) {
        switch projection {
        case let .amount(amount):
            event(.payment(.widget(.amount(amount))))
            
        case .buttonTapped:
            event(.continue)
        }
    }
}

private extension CachedModelsTransaction {
    
    var otpWarning: String? {
        
        guard case let .widget(.otp(_, warning)) = transaction.context.payment.elements[id: .widgetID(.otp)]
        else { return nil }
        
        return warning
    }
}
