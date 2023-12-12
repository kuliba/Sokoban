//
//  SberQRConfirmPaymentView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct SberQRConfirmPaymentView: View {
    
    let state: SberQRConfirmPaymentState
    let event: (SberQRConfirmPaymentEvent) -> Void
    let config: Config
    
    var body: some View {
        
        switch state {
        case let .editableAmount(editableAmount):
            EditableAmountSberQRConfirmPaymentView(
                state: editableAmount,
                event: { event(.editable($0)) }, 
                pay: { event(.pay) }
            )
            
        case let .fixedAmount(fixedAmount):
            FixedAmountSberQRConfirmPaymentView(
                state: fixedAmount,
                event: { event(.fixed($0)) }, 
                pay: { event(.pay) },
                config: config
            )
        }
    }
}

// MARK: - Previews

struct SberQRConfirmPaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        sberQRConfirmPaymentView(.editableAmount(.preview))
        sberQRConfirmPaymentView(.fixedAmount(.preview))
    }
    
    private static func sberQRConfirmPaymentView(
        _ state: SberQRConfirmPaymentState
    ) -> some View {
        
        SberQRConfirmPaymentView(
            state: state,
            event: { _ in },
            config: .default
        )
    }
}
