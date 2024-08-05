//
//  AnywayServicePickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class AnywayServicePickerFlowModel: ObservableObject {
    
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
    
    typealias State = AnywayServicePickerFlowState
    typealias Event = AnywayServicePickerFlowEvent
    typealias Effect = AnywayServicePickerFlowEffect
    typealias Factory = AnywayServicePickerFlowModelFactory
    
    typealias Content = State.Content
}

extension AnywayServicePickerFlowModel {
    
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

private extension AnywayServicePickerFlowModel {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        var effect: Effect?
        
        switch event {
        case .dismiss:
            state.status = nil
            
        case let .goTo(goTo):
            reduce(&state, &effect, with: goTo)
            
        case let .notify(result):
            reduce(&state, &effect, with: result)
            
        case .payByInstruction:
            payByInstructions(&state)
        }
        
        return nil
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        }
    }
}

private extension AnywayServicePickerFlowModel {
    
    func bind(_ content: Content) {
        
        state.content.$state
            .compactMap(\.response)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.notify($0)) }
            .store(in: &cancellables)
    }
}

private extension AnywayServicePickerFlowModel {
    
    private func payByInstructions(
        _ state: inout State
    ) {
        let paymentsViewModel = makePayByInstructionsModel()
        let cancellable = bind(paymentsViewModel)
        
        state.status = .destination(.payByInstructions(.init(
            model: paymentsViewModel,
            cancellable: cancellable
        )))
    }
    
    private func makePayByInstructionsModel() -> PaymentsViewModel {
        
        let makeModel = factory.makePayByInstructionsViewModel
        
        return makeModel { [weak self] in
            
            self?.event(.dismiss)
        }
    }
    
    private func bind(
        _ paymentsViewModel: PaymentsViewModel
    ) -> AnyCancellable {
        
        return paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
            .receive(on: scheduler)
            .sink { [weak self] a in self?.event(.goTo(.scanQR)) }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with goTo: Event.GoTo
    ) {
        switch goTo {
        case .addCompany:
            state.status = .outside(.addCompany)
            
        case .inflight:
            state.status = .outside(.inflight)
            
        case .main:
            state.status = .outside(.main)
            
        case .payments:
            state.status = .outside(.payments)
            
        case .scanQR:
            state.status = .outside(.scanQR)
        }
    }
    
    func reduce(
            _ state: inout State,
            _ effect: inout Effect?,
            with result: PaymentProviderServicePickerResult
        ) {
            switch result {
        case .failure(.connectivityError):
            state.status = .alert(.connectivity)
            
        case let .failure(.serverError(message)):
            state.status = .alert(.serverError(message))
            
        case let .success(transaction):
            let anywayFlowModel = factory.makeAnywayFlowModel(transaction)
            state.status = .destination(.payment(.init(
                model: anywayFlowModel,
                cancellable: bind(anywayFlowModel)
            )))
        }
    }
    
    private func bind(
        _ anywayFlowModel: AnywayFlowModel
    ) -> AnyCancellable {
        
        anywayFlowModel.$state
            .compactMap(\.outsideEvent)
            .receive(on: scheduler)
            .sink { [weak self] in self?.event($0) }
    }
}

private extension AnywayFlowState {
    
    var outside: Status.Outside? {
        
        guard case let .outside(outside) = status else { return nil }
        return outside
    }
    
    var outsideEvent: AnywayServicePickerFlowEvent? {
        
        switch outside {
        case .none:     return .none
        case .main:     return .goTo(.main)
        case .payments: return .goTo(.payments)
        }
    }
}
