//
//  PaymentsTransfersViewModelFactory+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

extension PaymentsTransfersViewModelFactory {
    
    static var preview: Self {
        
        return .init(
            makeUtilityPaymentViewModel: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion(.init())
                }
            }
        )
    }
}
