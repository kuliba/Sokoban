//
//  TemplatesListFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import Foundation

struct TemplatesListFlowState<Content>{
    
    let content: Content
    var status: Status?
}

extension TemplatesListFlowState {
 
    enum Status {
        
        case destination(Destination)
        case outside(Outside)
        
        enum Destination {
            
            case payment(PaymentsViewModel)
        }
        
        enum Outside: Equatable {
            
            case inflight
            case productID(ProductData.ID)
        }
    }
}
