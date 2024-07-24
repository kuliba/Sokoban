//
//  PaymentProviderServicePickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class PaymentProviderServicePickerFlowModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let reduce: Reduce
    private let handleEffect: HandleEffect
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        initialState: State,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.state = initialState
        self.reduce = reduce
        self.handleEffect = handleEffect
        
        bind(on: scheduler)
    }
}

extension PaymentProviderServicePickerFlowModel {
    
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
    
    func bind(
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
        
        let statePublisher = state.content.$state
            .receive(on: scheduler)
            .share()
        
        statePublisher
            .map(\.isLoading)
            .sink { [weak self] in self?.state.isContentLoading = $0 }
            .store(in: &cancellables)
        
        statePublisher
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
            
        case let .success(success):
            state.destination = .payment(success)
        }
    }
}
