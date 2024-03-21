//
//  PaymentParameter.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

enum PaymentParameter: Equatable {
    
    case input(InputParameter)
    case select(SelectParameter)
}

extension PaymentParameter: Identifiable {
    
    var id: ID {
        
        switch self {
        case .input:  return .input
        case .select: return .select
        }
    }
    
    enum ID {
        
        case input
        case select
    }
}
