//
//  PaymentsDataModel+Parameter.swift
//  ForaBank
//
//  Created by Max Gribov on 10.02.2022.
//

import Foundation

extension Payments.Parameter {
    
    init(value: Value, type: Kind, extra: Bool = false) {
        
        self.id = value.id
        self.value = value.value
        self.type = type
        self.extra = extra
    }
    
    func updated(with value: Value) -> Payments.Parameter {
        
        Payments.Parameter(value: value, type: type, extra: extra)
    }
    
    var parameterValue: Value {
        
        Value(id: id, value: value)
    }
}

extension Payments.Parameter {
   
    struct Service {
        
        let service: Payments.Service
        let icon: ImageData
        let title: String
        let description: String
    }
    
    struct Option {
        
        let id: String
        let name: String
        let icon: ImageData
    }
    
    struct OptionSimple {
        
        let id: String
        let name: String
    }
    
    struct InputValidator: ValidatorProtocol {
        
        let minLength: Int
        let maxLength: Int?
        let regEx: String?
        
        func isValid(value: String) -> Bool {
            
            guard value.count >= minLength else {
                return false
            }
            
            if let maxLength = maxLength {
                
                guard value.count < maxLength else {
                    return false
                }
            }
            
            //TODO: validate with regex if present
            
            return true
        }
    }
    
    struct AmountValidator: ValidatorProtocol {
        
        let minAmount: Double
        
        func isValid(value: Double) -> Bool {
            
            guard value >= minAmount else {
                return false
            }
            
            return true
        }
    }
    
    enum ID: String {
        
        case service
        case `operator`
    }

    struct Value {
        
        let id: String
        let value: String
    }
}
