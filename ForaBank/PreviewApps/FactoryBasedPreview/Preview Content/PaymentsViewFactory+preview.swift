//
//  PaymentsViewFactory+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

extension PaymentsViewFactory where DestinationView == Text {
    
    static var preview: Self {
        
        .init(
            makeDestinationView: {
                
                Text("Destination View: \(String(describing: $0))")
            }
        )
    }
}
