//
//  TemplatesListFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

enum TemplatesListFlowEvent: Equatable {
    
    case dismiss(Dismiss)
    case select(Select)
}

extension TemplatesListFlowEvent {
    
    enum Dismiss: Equatable {
        
        case destination
    }
    
    enum Select: Equatable {
        
        case productID(ProductID)
        case template(Template)
        
        typealias ProductID = ProductData.ID
        typealias Template = PaymentTemplateData
    }
}
