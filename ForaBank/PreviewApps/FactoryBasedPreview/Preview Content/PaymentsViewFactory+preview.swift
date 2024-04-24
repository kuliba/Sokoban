//
//  PaymentsViewFactory+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

extension PaymentsViewFactory
where DestinationView == Text,
      PaymentButtonLabel == Text {
    
    static var preview: Self {
        
        .init(
            makeDestinationView: {
                
                Text("Destination View: \(String(describing: $0))")
            },
            makePaymentButtonLabel: {
                
                switch $0 {
                case .mobile:
                    Text("Cellular Service")
                    
                case .utilityService:
                    Text("Utility Service")
                }
            }
        )
    }
}
