//
//  PaymentsState+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

extension PaymentsState {
    
    static func preview(
        _ destination: Destination? = nil
    ) -> Self {
        
        .init(destination: destination)
    }
}
