//
//  PaymentsParameterViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 19.02.2022.
//

import Foundation
import Combine

class PaymentsParameterViewModel: Identifiable, ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var value: Value
    @Published var isEditable: Bool
    
    var isValid: Bool { true }
    var isFullContent: Bool { false }
    
    var id: Payments.Parameter.ID { source.parameter.id }
    var result: Payments.Parameter { .init(id: id, value: value.current) }
    
    private(set) var source: PaymentsParameterRepresentable
    
    init(source: PaymentsParameterRepresentable) {
        
        self.value = .init(with: source)
        self.source = source
        self.isEditable = source.isEditable
    }
    
    func update(value: String?) {
        
        self.value = self.value.updated(with: value)
    }
    
    func update(source: PaymentsParameterRepresentable) {
        
        self.source = source
    }
    
    func updateEditable(update: EditableUpdate) {
        
        switch update {
        case let .value(value):
            isEditable = value
            
        case .source:
            isEditable = source.isEditable
        }
    }
}

//MARK: - Types

extension PaymentsParameterViewModel {
    
    struct Value {
 
        let id: Payments.Parameter.ID
        let original: String?
        let current: String?
        
        var isChanged: Bool { original != current }
        
        internal init(id: Payments.Parameter.ID, original: String?, current: String?) {
            
            self.id = id
            self.original = original
            self.current = current
        }
        
        init(with representable: PaymentsParameterRepresentable) {
            
            self.id = representable.parameter.id
            self.original = representable.parameter.value
            self.current = representable.parameter.value
        }
        
        func updated(with value: String?) -> Value {
            
            .init(id: id, original: original, current: value)
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
