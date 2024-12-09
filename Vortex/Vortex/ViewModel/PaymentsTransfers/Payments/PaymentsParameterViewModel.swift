//
//  PaymentsParameterViewModel.swift
//  Vortex
//
//  Created by Max Gribov on 19.02.2022.
//

import Foundation
import Combine

class PaymentsParameterViewModel: Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let id: String
    
    @Published private(set) var value: Value
    @Published private(set) var isEditable: Bool
    
    var isValid: Bool { true }
    var isFullContent: Bool { false }
    
    /// on value change of this parameter runs all parameters validation checks
    var isValidationChecker: Bool { false }
    
    var result: Payments.Parameter { .init(id: source.id, value: value.current) }
    var parameterValue: ((Payments.Parameter.ID) -> Payments.Parameter.Value)?
    
    private(set) var source: PaymentsParameterRepresentable
    internal var bindings = Set<AnyCancellable>()
    
    init(source: PaymentsParameterRepresentable) {
        
        self.id = source.id
        self.value = .init(with: source)
        self.source = source
        self.isEditable = source.isEditable
    }
    
    func update(value: String?) {
        
        self.value = self.value.updated(with: value)
    }
    
    func update(source: PaymentsParameterRepresentable) {
        
        self.source = source
        update(value: source.value)
        self.isEditable = source.isEditable
    }
    
    func updateCurrencyIsChanged(currencyIsChanged: Bool = false) {
        
        self.value.currencyIsChanged = currencyIsChanged
    }
    
    func updateEditable(update: EditableUpdate) {
        
        switch update {
        case let .value(value):
            isEditable = value
            
        case .source:
            isEditable = source.isEditable
        }
    }
    
    /// if parameter's value is invalid the parameter must show validation warning
    func updateValidationWarnings() {
        
        // implement in subclass
    }
}

//MARK: - Types

extension PaymentsParameterViewModel {
    
    struct Value: Equatable {
 
        let id: Payments.Parameter.ID
        let last: String?
        let current: String?
        
        var isChanged: Bool { last != current }
        var currencyIsChanged: Bool = false
        
        internal init(id: Payments.Parameter.ID, last: String?, current: String?) {
            
            self.id = id
            self.last = last
            self.current = current
        }
        
        init(with representable: PaymentsParameterRepresentable) {
            
            self.id = representable.parameter.id
            self.last = representable.parameter.value
            self.current = representable.parameter.value
        }
        
        func updated(with value: String?) -> Value {
            
            .init(id: id, last: current, current: value)
        }
    }
    
    enum EditableUpdate {
        
        /// set concrete value
        case value(Bool)
        
        /// set data from source parameter
        case source
    }
}

//MARK: - Action

enum PaymentsParameterViewModelAction {}

//MARK: - Protocols

protocol PaymentsParameterViewModelContinuable {
    
    func update(isContinueEnabled: Bool)
}

protocol PaymentsParameterViewModelWarnable {
    
    func update(warning: String)
}

//MARK: Helpers

extension PaymentsParameterViewModel {
    
    var isHidden: Bool {
        
        return (source as? Payments.ParameterHidden) != nil
    }
    
    var isNotHidden: Bool {
        
        return !isHidden
    }
}
