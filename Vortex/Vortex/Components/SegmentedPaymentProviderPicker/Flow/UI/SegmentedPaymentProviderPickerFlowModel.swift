//
//  SegmentedPaymentProviderPickerFlowModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class SegmentedPaymentProviderPickerFlowModel: ObservableObject {
    
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
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
    }
    
    typealias State = SegmentedPaymentProviderPickerFlowState
    typealias Event = SegmentedPaymentProviderPickerFlowEvent
    typealias Effect = SegmentedPaymentProviderPickerFlowEffect
    typealias Factory = SegmentedPaymentProviderPickerFlowFactory
    
    typealias Content = State.Content
}

extension SegmentedPaymentProviderPickerFlowModel {
    
    func event(_ event: Event) {
        
        _ = reduce(&state, event)
        stateSubject.send(state)
    }
}

private extension SegmentedPaymentProviderPickerFlowModel {
    
    func reduce(
        _ state: inout State,
        _ event: Event
    ) -> Effect? {
        
        state.isLoading = false
        let effect: Effect? = nil
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .goTo(goTo):
            return reduce(&state, with: goTo)
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case .payByInstructions:
            payByInstructions(&state)
            
        case let .select(select):
            return reduce(&state, with: select)
        }
        
        return effect
    }
    
    func reduce(
        _ state: inout State,
        with goTo: Event.GoTo
    ) -> Effect? {
        
        switch goTo {
        case .addCompany:
            state.navigation = .outside(.addCompany)
            
        case .main:
            state.navigation = .outside(.main)
            
        case .payments:
            state.navigation = .outside(.payments)
            
        case .scanQR:
            state.navigation = .outside(.scanQR)
        }
        
        return nil
    }
    
    func reduce(
        _ state: inout State,
        with select: Event.Select
    ) -> Effect? {
        
        switch select {
        case let .operator(`operator`):
            payWithOperator(&state, `operator`)
            
        case let .provider(provider):
            payWithProvider(&state, provider)
        }
        
        return nil
    }
}

// MARK: - pay with operator

private extension SegmentedPaymentProviderPickerFlowModel {
    
    func payWithOperator(
        _ state: inout State,
        _ `operator`: State.Navigation.Operator
    ) {
        let paymentsViewModel = makePaymentsViewModel(with: `operator`)
        
        state.navigation = .destination(.payments(.init(
            model: paymentsViewModel,
            cancellable: bind(paymentsViewModel)
        )))
    }
    
    private func makePaymentsViewModel(
        with `operator`: State.Navigation.Operator
    ) -> PaymentsViewModel {
        
        let qrCode = state.content.qrCode
        
        return factory.makePaymentsViewModel(`operator`, qrCode) { [weak self] in
            
            self?.event(.dismiss)
        }
    }
}

// MARK: - pay with provider

private extension SegmentedPaymentProviderPickerFlowModel {
    
    func payWithProvider(
        _ state: inout State,
        _ provider: State.Navigation.Provider
    ) {
        let qrCode = state.content.qrCode
        let qrMapping = state.content.qrMapping
        let flowModel = factory.makeServicePickerFlowModel(.init(
            provider: provider,
            qrCode: qrCode,
            qrMapping: qrMapping
        ))
        
        state.navigation = .destination(.servicePicker(.init(
            model: flowModel,
            cancellables: bind(flowModel)
        )))
    }
    
    private func bind(
        _ flowModel: AnywayServicePickerFlowModel
    ) -> Set<AnyCancellable> {
        
        let loading = flowModel.$state
            .map(\.isLoading)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.isLoading($0)) }
        
        let outside = flowModel.$state
            .compactMap(\.outsideEvent)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.goTo($0)) }
        
        return [loading, outside]
    }
}

extension AnywayServicePickerFlowState {
    
    var outside: Status.Outside? {
        
        guard case let .outside(outside) = status else { return nil }
        return outside
    }
}

private extension AnywayServicePickerFlowState {
    
    var outsideEvent: SegmentedPaymentProviderPickerFlowEvent.GoTo? {
        
        switch outside {
        case .none:       return .none
        case .addCompany: return .addCompany
        case .main:       return .main
        case .payments:   return .payments
        case .scanQR:     return .scanQR
        }
    }
}

// MARK: - payByInstructions

private extension SegmentedPaymentProviderPickerFlowModel {
    
    func payByInstructions(
        _ state: inout State
    ) {
        let paymentsViewModel = makePayByInstructionsModel()
        
        state.navigation = .destination(.payByInstructions(.init(
            model: paymentsViewModel,
            cancellable: bind(paymentsViewModel)
        )))
    }
    
    private func makePayByInstructionsModel() -> PaymentsViewModel {
        
        let qrCode = state.content.qrCode
        
        return factory.makePayByInstructionsViewModel(qrCode) { [weak self] in
            
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
}
