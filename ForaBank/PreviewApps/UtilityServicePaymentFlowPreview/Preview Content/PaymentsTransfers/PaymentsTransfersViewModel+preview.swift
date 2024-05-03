//
//  PaymentsTransfersViewModel+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

extension PaymentsTransfersViewModel {
    
    static func preview() -> Self {
        
        return .init(state: .preview, factory: .preview, navigationStateManager: .preview(), rootActions: .preview)
    }
}
