//
//  AnywayPaymentWidgetView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import SwiftUI

struct AnywayPaymentWidgetView: View {
    
    let widget: Widget
    let event: (Event) -> Void
    
    var body: some View {
        
        switch widget {
        case let .otp(otp):
            #warning("replace with real components")
            HStack {
                
                Text("OTP: " + (otp.map { "\($0)" } ?? ""))
                TextField(
                    "Введите код", 
                    text: .init(
                        get: { otp.map { "\($0)" } ?? "" },
                        set: { event(.otp($0)) }
                    )
                )
            }
            #warning("can't use CodeInputView - not a part  af any product (neither PaymentComponents nor any other)")
            #warning("need a wrapper with timer")
//            CodeInputView(
//                state: <#T##OTPInputState.Status.Input#>, 
//                event: <#T##(OTPInputEvent) -> Void#>,
//                config: <#T##CodeInputConfig#>
//            )
            
        case let .productPicker(productID):
            #warning("replace with real components")
            Text("productID \(productID)")
        }
    }
}

extension AnywayPaymentWidgetView {
    
    typealias Widget = AnywayPayment.Element.UIComponent.Widget
    typealias Event = AnywayPaymentEvent.Widget
}

#Preview {
    
    Group {
        AnywayPaymentWidgetView(widget: .otp(nil), event: { print($0) })
        AnywayPaymentWidgetView(widget: .otp(123), event: { print($0) })
        AnywayPaymentWidgetView(widget: .otp(123456), event: { print($0) })
    }
}

#Preview {
    AnywayPaymentWidgetView(widget: .productPicker(.accountID(12345)), event: { print($0) })
}
