//
//  AnywayPaymentElementViewFactory+preview.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 16.04.2024.
//

import AnywayPaymentCore
import SwiftUI

extension AnywayPaymentElementViewFactory
where FieldView == AnywayPaymentElementFieldView,
      ParameterView == AnywayPaymentElementParameterView,
      WidgetView == AnywayPaymentElementWidgetView<OTPMockView, Text> {
    
    static var preview: Self {
        
        .init(
            fieldView: FieldView.init,
            parameterView: ParameterView.init,
            widgetView: { .init(state: $0, event: $1, factory: .preview) }
        )
    }
}
