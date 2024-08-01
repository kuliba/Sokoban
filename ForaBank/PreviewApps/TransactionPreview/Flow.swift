//
//  Flow.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

struct Flow {
    
    var destination: Destination?
    var modal: Modal?
}

extension Flow {
    
    enum Destination: Identifiable {
        
        case payment(ObservingCachedAnywayTransactionViewModel)
        
        var id: ID {
            
            switch self {
            case let  .payment(viewModel):
                return .payment(ObjectIdentifier(viewModel))
            }
        }
        
        enum ID: Hashable {
            
            case payment(ObjectIdentifier)
        }
    }
    
    enum Modal: Identifiable {
        
        case fraud
        case eventList
        
        var id: ID {
            switch self {
            case .fraud:
                return .fraud
                
            case .eventList:
                return .eventList
            }
        }
        
        enum ID: Hashable {
            
            case fraud
            case eventList
        }
    }
}
