//
//  TemplatesListFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import Foundation

protocol ProductIDEmitter {
    
    typealias ProductID = ProductData.ID

    var productIDPublisher: AnyPublisher<ProductID, Never> { get }
}

struct TemplatesListFlowState<Content>
where Content: ProductIDEmitter {
    
    let content: Content
    var status: Status?
}

extension TemplatesListFlowState {
 
    enum Status: Equatable {
        
        case outside(Outside)
        
        enum Outside: Equatable {
            
            case productID(ProductData.ID)
        }
    }
}
