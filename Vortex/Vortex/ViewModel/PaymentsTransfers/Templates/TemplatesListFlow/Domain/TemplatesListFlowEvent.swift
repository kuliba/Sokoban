//
//  TemplatesListFlowEvent.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.08.2024.
//

enum TemplatesListFlowEvent<PaymentFlow> {
    
    case dismiss(Dismiss)
    case flow(DismissAndTabFlowEvent)
    case payment(PaymentResult)
    case select(Select)
}

extension TemplatesListFlowEvent {
    
    enum Dismiss: Equatable {
        
        case destination
    }
    
    typealias PaymentResult = Result<Payment, ServiceFailure>
    
    enum Payment {
        
        case legacy(PaymentsViewModel)
        case v1(Node<PaymentFlow>)
    }
    
    typealias ServiceFailure = ServiceFailureAlert.ServiceFailure

    enum Select: Equatable {
        
        case productID(ProductID)
        case template(Template)
        
        typealias ProductID = ProductData.ID
        typealias Template = PaymentTemplateData
    }
}
