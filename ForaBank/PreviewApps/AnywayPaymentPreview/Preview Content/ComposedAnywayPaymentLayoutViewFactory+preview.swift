//
//  ComposedAnywayPaymentLayoutViewFactory+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 16.04.2024.
//

import SwiftUI

extension ComposedAnywayPaymentViewFactory
where FieldView == AnywayPaymentElementFieldView,
      OTPView == OTPMockView,
      ParameterView == AnywayPaymentElementParameterView,
      ProductPicker == Text {
    
    static var preview: Self {
        
        .init(
            fieldView: FieldView.init,
            otpView: OTPView.init,
            parameterView: ParameterView.init,
            productPicker: { Text("TBD: Product Picker (Selector): \($0), \(String(describing: $1))") }
        )
    }
}
