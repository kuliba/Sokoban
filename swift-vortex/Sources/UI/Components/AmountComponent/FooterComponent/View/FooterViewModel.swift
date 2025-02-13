//
//  FooterViewModel.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import Combine
import Foundation
import TextFieldDomain
import TextFieldComponent

public final class FooterViewModel: ObservableObject {
    
    @Published public private(set) var state: State
    
    let textFieldModel: DecimalTextFieldViewModel
    
    private let reduce: Reduce
    private let format: Format
    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var hasSetInitialValue = false
    
    public init(
        initialState: State,
        reduce: @escaping Reduce,
        format: @escaping Format,
        getDecimal: @escaping GetDecimal,
        textFieldModel: DecimalTextFieldViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.textFieldModel = textFieldModel
        self.reduce = reduce
        self.format = format
        
        setupTextFieldSubscription(getDecimal: getDecimal, scheduler: scheduler)
        setupStateSubscription(scheduler: scheduler)
        setupInitialValue(initialState: initialState)
    }
    
    private func setupTextFieldSubscription(
        getDecimal: @escaping GetDecimal,
        scheduler: AnySchedulerOfDispatchQueue
    ) {
        textFieldModel.$state
            .map(getDecimal)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] newAmount in
                
                guard let self = self, self.hasSetInitialValue else { return }
                self.state.amount = newAmount
            }
            .store(in: &cancellables)
    }
    
    private func setupStateSubscription(
        scheduler: AnySchedulerOfDispatchQueue
    ) {
        stateSubject
            .receive(on: scheduler)
            .sink { [weak self] newState in
                
                guard let self = self else { return }
                self.state = newState
                
                if let formattedValue = self.format(newState.amount) {
                    self.textFieldModel.setText(to: formattedValue)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupInitialValue(initialState: State) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            if let formattedValue = self.format(initialState.amount) {
                self.textFieldModel.setText(to: formattedValue)
                self.hasSetInitialValue = true
            }
        }
    }
}

public extension FooterViewModel {
    
    typealias State = FooterState
    typealias Event = FooterEvent
    typealias Effect = FooterEffect
    
    typealias Reduce = (State, Event) -> (State, FooterEffect?)
    typealias GetDecimal = (TextFieldState) -> Decimal
    typealias Format = (Decimal) -> String?
}

public extension FooterViewModel {
    
    func event(_ event: Event) {
        
        notifyTextField(event)
        stateSubject.send(reduce(state, event).0)
    }
}

private extension FooterViewModel {
    
    func notifyTextField(_ event: Event) {
        
        switch event {
        case .button(.tap):
            textFieldModel.finishEditing()
            
        case let .edit(amount):
            textFieldModel.setText(to: format(amount))
            
        default:
            break
        }
    }
}
