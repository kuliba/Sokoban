//
//  ElementView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct ElementView: View {
    
    let state: AnywayPayment.Element
    let event: (AnywayPaymentEvent) -> Void
    
    var body: some View {
        
        switch state.uiComponentType {
        case let .field(field):
            Text(String(describing: field))
            
        case .parameter:
            Text(String(describing: state))
            
        case .widget(.otp):
            state.otp.map {
                
                OTPView(
                    state: $0,
                    event: { event(.otp($0)) }
                )
            }
            
        case .widget(.productPicker):
            Text("TBD: Product Picker (Selector)")
        }
    }
}

private extension AnywayPayment.Element {
    
    var otp: String? {
        
        guard case let .widget(.otp(otp)) = self
        else { return nil }
        
        return otp
    }
}

struct ElementView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ElementView(
            state: .widget(.otp("123")),
            event: { _ in }
        )
    }
}
