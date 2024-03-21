//
//  PaymentParameter.swift
//
//
//  Created by Igor Malyarov on 21.03.2024.
//

enum PaymentParameter: Equatable {
    
    case select(SelectParameter)
}

extension PaymentParameter: Identifiable {
    
    var id: ID {
        
        switch self {
        case .select: return .select
        }
    }
    
    enum ID {
        
        case select
    }
}
