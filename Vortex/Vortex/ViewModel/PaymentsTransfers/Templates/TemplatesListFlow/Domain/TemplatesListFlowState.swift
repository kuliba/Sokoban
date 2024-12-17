//
//  TemplatesListFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import Foundation

struct TemplatesListFlowState<Content, PaymentFlow>{
    
    let content: Content
    var isLoading = false
    var status: Status?
}

extension TemplatesListFlowState {
 
    enum Status {
        
        case alert(ServiceFailure)
        case destination(Destination)
        case outside(Outside)
        
        typealias ServiceFailure = ServiceFailureAlert.ServiceFailure
        
        enum Destination {
            
            case payment(Payment)
            
            enum Payment {
                 
                case legacy(PaymentsViewModel)
                case v1(Node<PaymentFlow>)
            }
        }
        
        enum Outside: Equatable {
            
            case productID(ProductData.ID)
            case tab(Tab)
            
            enum Tab: Equatable {
                
                case main, payments
            }
        }
    }
}

extension TemplatesListFlowState {
    
    var external: ExternalTemplatesListFlowState {
        
        .init(isLoading: isLoading, outside: outside)
    }
    
    var outside: Status.Outside? {
        
        guard case let .outside(outside) = status
        else { return nil }
 
        return outside
    }

    struct ExternalTemplatesListFlowState: Equatable {
        
        let isLoading: Bool
        let outside: Status.Outside?
    }
}
