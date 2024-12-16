//
//  AnywayPaymentElementWidgetViewFactory+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 16.04.2024.
//

import AnywayPaymentDomain
import SwiftUI

extension AnywayPaymentElementWidgetViewFactory
where OTPView == OTPMockView,
      ProductPicker == Text {
    
    static var preview: Self {
        
        .init(
            otpView: OTPMockView.init,
            productPicker: { Text("TBD: Product Picker (Selector): \($0), \(String(describing: $1))") }
        )
    }
}
