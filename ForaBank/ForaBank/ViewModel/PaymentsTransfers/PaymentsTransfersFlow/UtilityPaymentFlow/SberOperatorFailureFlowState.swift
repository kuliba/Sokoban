//
//  SberOperatorFailureFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.05.2024.
//

struct SberOperatorFailureFlowState<Content> {
    
    let content: Content
    var destination: Destination?
    
    init(
        content: Content,
        destination: Destination? = nil
    ) {
        self.content = content
        self.destination = destination
    }
}

extension SberOperatorFailureFlowState {
    
    enum Destination {
        
        case payByInstructions(PaymentsViewModel)
    }
}
