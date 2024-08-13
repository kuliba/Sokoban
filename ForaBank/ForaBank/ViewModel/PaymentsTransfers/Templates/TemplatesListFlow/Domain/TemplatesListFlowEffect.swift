//
//  TemplatesListFlowEffect.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

enum TemplatesListFlowEffect: Equatable {
    
    case template(Template)

}

extension TemplatesListFlowEffect {
    
    typealias Template = PaymentTemplateData
}
