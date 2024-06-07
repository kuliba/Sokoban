//
//  AnywayPaymentElementWidgetViewFactory.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 16.04.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentElementWidgetViewFactory<OTPView, ProductPicker>
where OTPView: View,
      ProductPicker: View {
    
    let otpView: MakeOTPView
    let productPicker: MakeProductPicker
}

extension AnywayPaymentElementWidgetViewFactory {
    
    typealias MakeOTPView = (String, @escaping (String) -> Void) -> OTPView
    typealias MakeProductPicker = (AnywayPayment.AnywayElement.UIComponent.Widget.ProductID, @escaping (AnywayPaymentEvent.Widget.ProductID, AnywayPaymentEvent.Widget.Currency) -> Void) -> ProductPicker
}
