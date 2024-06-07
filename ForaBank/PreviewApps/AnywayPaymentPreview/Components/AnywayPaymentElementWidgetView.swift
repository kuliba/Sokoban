//
//  AnywayPaymentElementWidgetView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentElementWidgetView<OTPView, ProductPicker>: View
where OTPView: View,
      ProductPicker: View {
    
    let state: AnywayElement.UIComponent.Widget
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

struct AnywayPaymentElementWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentElementWidgetView(
            state: .preview,
            event: { _ in },
            factory: .preview
        )
    }
}
