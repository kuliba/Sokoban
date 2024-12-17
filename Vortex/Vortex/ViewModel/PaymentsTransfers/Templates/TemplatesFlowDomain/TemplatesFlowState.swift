//
//  TemplatesFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.07.2024.
//

enum TemplatesFlowState: Equatable {
    
    case legacy(PaymentTemplateData)
    case v1
}
