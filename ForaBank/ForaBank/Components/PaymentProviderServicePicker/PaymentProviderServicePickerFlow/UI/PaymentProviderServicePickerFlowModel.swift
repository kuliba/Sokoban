//
//  PaymentProviderServicePickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import Combine
import CombineSchedulers
import Foundation

@available(*, deprecated, message: "use AnywayServicePickerFlowModel instead")
final class PaymentProviderServicePickerFlowModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let factory: Factory
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private var cancellables = Set<AnyCancellable>()
    
    init(
        initialState: State,
        factory: Factory,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.factory = factory
        self.reduce = reduce
        self.handleEffect = handleEffect
        self.scheduler = scheduler
        
        bind(on: scheduler)
    }
}

extension PaymentProviderServicePickerFlowModel {
    
    typealias Factory = PaymentProviderServicePickerFlowModelFactory
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping (Event) -> Void) -> Void
    
    typealias State = PaymentProviderServicePickerFlowState
    typealias Event = PaymentProviderServicePickerFlowEvent
    typealias Effect = PaymentProviderServicePickerFlowEffect
}

extension PaymentProviderServicePickerFlowModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] event in
                
                self?.event(event)
            }
        }
    }
}

private extension PaymentProviderServicePickerFlowModel {
    
    func bind(on scheduler: AnySchedulerOf<DispatchQueue>) {
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
        
        let contentStatePublisher = state.content.$state
            .receive(on: scheduler)
            .share()
        
        contentStatePublisher
            .map(\.isLoading)
            .sink { [weak self] in self?.state.isContentLoading = $0 }
            .store(in: &cancellables)
        
        contentStatePublisher
            .map(\.response)
            .sink { [weak self] in self?.handleResponse($0) }
            .store(in: &cancellables)
    }
    
    func handleResponse(
        _ response: PaymentProviderServicePickerResult?
    ) {
        switch response {
        case .none:
            state.alert = nil
            state.destination = nil
            
        case let .failure(failure):
            state.alert = .init(serviceFailure: failure)
            
        case let .success(transaction):
            let binder = factory.makeServicePaymentBinder(transaction)
            bind(binder)
            state.destination = .payment(binder)
        }
    }
    
    func bind(_ binder: ServicePaymentBinder) {
        
#warning("fix subscription")
        binder.flow.$state
            .sink { [weak self] _ in _ = self }
            .store(in: &cancellables)
    }
}
