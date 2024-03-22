//
//  PaymentParameter.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

struct PaymentParameter: Equatable {
    
    var parameter: Parameter
    var isValid: Bool
}

extension PaymentParameter {
    
    enum Parameter: Equatable {
        
        case input(InputParameter)
        case select(SelectParameter)
    }
}

extension PaymentParameter: Identifiable {
    
    var id: ID {
        
        switch parameter {
        case .input:  return .input
        case .select: return .select
        }
    }
    
    enum ID {
        
        case input
        case select
    }
}
