//
//  PaymentProviderPickerFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class PaymentProviderPickerFlowModel: ObservableObject {
    
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
    
    typealias State = PaymentProviderPickerFlowState<Operator, Provider>
    typealias Event = PaymentProviderPickerFlowEvent<Operator, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect
    typealias Factory = PaymentProviderPickerFlowFactory

    typealias Content = State.Content

    typealias Operator = SegmentedOperatorData
    typealias Provider = SegmentedProvider
}

extension PaymentProviderPickerFlowModel {
    
    func event(_ event: Event) {
        
        _ = reduce(&state, event)
        stateSubject.send(state)
    }
}

private extension PaymentProviderPickerFlowModel {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        let effect: Effect? = nil
        
        switch event {
        case .addCompany:
            state.destination = .addCompany
            
        case .dismiss:
            state.destination = nil
            
        case let .operator(`operator`):
            state.destination = .operator(`operator`)
            
        case .payByInstructions:
            payByInstructions(&state)
            
        case let .provider(provider):
            state.destination = .provider(provider)
            
        case .scanQR:
            state.destination = .scanQR
        }
        
        return effect
    }
    
    private func payByInstructions(
        _ state: inout State
    ) {
        let paymentsViewModel = makePayByInstructionsModel()
        let cancellable = bind(paymentsViewModel)
        
        state.destination = .payByInstructions(.init(
            model: paymentsViewModel,
            cancellable: cancellable
        ))
    }
    
    private func makePayByInstructionsModel() -> PaymentsViewModel {
        
        let qrCode = state.content.state.qrCode
        let makeModel = factory.makePayByInstructionsViewModel
        
        return makeModel(qrCode) { [weak self] in
            
            self?.event(.dismiss)
        }
    }
    
    private func bind(
        _ paymentsViewModel: PaymentsViewModel
    ) -> AnyCancellable {
        
        return paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
            .receive(on: scheduler)
            .sink { [weak self] a in self?.event(.scanQR) }
    }
}

private extension PaymentProviderPickerFlowModel {
    
    func bind(_ content: Content) {
        
        state.content.$state
            .compactMap(\.selection)
            .receive(on: scheduler)
            .sink { [weak self] in
                
                switch $0 {
                case .addCompany:
                    self?.event(.addCompany)
                    
                case let .item(.operator(`operator`)):
                    self?.event(.operator(`operator`))
                    
                case let .item(.provider(provider)):
                    self?.event(.provider(provider))
                    
                case .payByInstructions:
                    self?.event(.payByInstructions)
                }
            }
            .store(in: &cancellables)
    }
}
