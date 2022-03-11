//
//  PaymentsParameterViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 19.02.2022.
//

import Foundation

class PaymentsParameterViewModel: Identifiable, ObservableObject {
    
    //TODO: добавить свойство let isEditable: Bool
    
    
    @Published var value: Value
    var isValid: Bool {
        
        return true
    }
    
    var id: Payments.Parameter.ID { source.parameter.id }
    var result: Payments.Parameter { .init(id: id, value: value.current)}
    
    internal let source: ParameterRepresentable
    
    init(source: ParameterRepresentable) {
        
        self.value = .init(with: source)
        self.source = source
    }
    
    func update(value: String?) {
        
        self.value = self.value.updated(with: value)
    }
    
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
        
        init(with representable: ParameterRepresentable) {
            
            self.id = representable.parameter.id
            self.original = representable.parameter.value
            self.current = representable.parameter.value
        }
        
        func updated(with value: String?) -> Value {
            
            .init(id: id, original: original, current: value)
        }
    }
}
