//
//  AnywayPaymentElementWidgetView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentElementWidgetView: View {
    
    let state: AnywayPayment.UIComponent.Widget
    let event: (AnywayPaymentEvent.Widget) -> Void
    
    var body: some View {
        
        switch state {
        case let .otp(otp):
            otpView(
                state: otp.map(String.init) ?? "",
                event: { event(.otp($0)) }
            )
            
        case let .productPicker(productID):
            productPicker(
                state: productID,
                event: { event(.product($0, $1)) }
            )
        }
    }
    
    private func otpView(
        state: String,
        event: @escaping (String) -> Void
    ) -> some View {
        
        OTPView(state: state, event: event)
    }
    
    private func productPicker(
        state: AnywayPayment.UIComponent.Widget.ProductID,
        event: @escaping (AnywayPaymentEvent.Widget.ProductID, AnywayPaymentEvent.Widget.Currency) -> Void
    ) -> some View {
        
        Text("TBD: Product Picker (Selector)")
    }
}

struct AnywayPaymentElementWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentElementWidgetView(state: .preview, event: { _ in })
    }
}
