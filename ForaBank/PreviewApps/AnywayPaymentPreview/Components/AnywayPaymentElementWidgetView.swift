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
    let event: (AnywayPaymentEvent) -> Void
    
    var body: some View {
        
        switch state {
        case let .otp(otp):
            OTPView(state: otp.asString, event: { event(.widget(.otp($0))) })
            
        case .productPicker:
            Text("TBD: Product Picker (Selector)")
        }
    }
}

private extension Optional where Wrapped == Int {
    
    var asString: String {
        
        return map(String.init) ?? ""
    }
}

struct AnywayPaymentElementWidgetView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentElementWidgetView(state: .preview, event: { _ in })
    }
}
