//
//  BottomAmountViewModel.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import Combine
import Foundation
import TextFieldDomain
import TextFieldComponent

final class BottomAmountViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    let textFieldModel: DecimalTextFieldViewModel
    
    private let reduce: Reduce
    private let formatter: DecimalFormatter
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        initialState: State,
        reduce: @escaping Reduce,
        formatter: DecimalFormatter,
        textFieldModel: DecimalTextFieldViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.reduce = reduce
        self.textFieldModel = textFieldModel
        self.formatter = formatter
        
        textFieldModel.setText(to: formatter.format(initialState.value))
        
        textFieldModel.$state
            .dropFirst(2)
            .map(formatter.getDecimal)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in
                
                print(self.map(ObjectIdentifier.init) ?? "", "sink", $0)
                self?.state.value = $0
            }
            .store(in: &cancellables)
        
        stateSubject
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension BottomAmountViewModel {
    
    typealias State = BottomAmount
    typealias Event = BottomAmountEvent
    
    typealias Reduce = (State, Event) -> (State, Never?)
    typealias GetDecimal = (TextFieldState) -> Decimal
}

extension BottomAmountViewModel {
    
    func event(_ event: Event) {
        
        switch event {
        case .button(.tap):
            textFieldModel.finishEditing()
            
        case let .edit(amount):
            textFieldModel.setText(to: formatter.format(amount))
            
        default:
            break
        }
        
        let (state, _) = reduce(state, event)
        stateSubject.send(state)
    }
}
