//
//  PaymentsTransfersViewFactory+preview.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

extension PaymentsTransfersViewFactory
where DestinationView == Text {
    
    static var preview: Self {
        
        return .init(makeDestinationView: { _ in .init("DestinationView") })
    }
}
