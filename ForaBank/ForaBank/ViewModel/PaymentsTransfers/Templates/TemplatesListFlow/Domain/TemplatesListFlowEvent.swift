//
//  TemplatesListFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

enum TemplatesListFlowEvent {
    
    case select(ProductID)
}

extension TemplatesListFlowEvent {
    
    typealias ProductID = ProductData.ID
}
