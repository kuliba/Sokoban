//
//  PrepaymentFlowState+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension PrepaymentFlowState {
    
    static func preview(
        _ destination: Destination? = nil
    ) -> Self {
        
        .init(destination: destination)
    }
}
