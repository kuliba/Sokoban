//
//  AnywayPaymentElementWidgetView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentElementWidgetViewFactory<OTPView, ProductPicker>
where OTPView: View,
      ProductPicker: View {
    
    let otpView: MakeOTPView
    let productPicker: MakeProductPicker
}

extension AnywayPaymentElementWidgetViewFactory {
    
    typealias MakeOTPView = (String, @escaping (String) -> Void) -> OTPView
    typealias MakeProductPicker = (AnywayPayment.UIComponent.Widget.ProductID, @escaping (AnywayPaymentEvent.Widget.ProductID, AnywayPaymentEvent.Widget.Currency) -> Void) -> ProductPicker
}

struct AnywayPaymentElementWidgetView<OTPView, ProductPicker>: View
where OTPView: View,
      ProductPicker: View {
    
    let state: AnywayPayment.UIComponent.Widget
    let event: (AnywayPaymentEvent.Widget) -> Void
    let factory: AnywayPaymentElementWidgetViewFactory<OTPView, ProductPicker>
    
    var body: some View {
        
        switch state {
        case let .otp(otp):
            factory.otpView(
                otp.map(String.init) ?? "",
                { event(.otp($0)) }
            )
            
        case let .productPicker(productID):
            factory.productPicker(
                productID,
                { event(.product($0, $1)) }
            )
        }
    }
}

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

struct AnywayPaymentElementWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentElementWidgetView(
            state: .preview,
            event: { _ in },
            factory: .preview
        )
    }
}
