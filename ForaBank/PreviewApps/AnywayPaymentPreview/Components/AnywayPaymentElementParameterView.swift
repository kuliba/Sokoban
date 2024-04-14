//
//  AnywayPaymentElementParameterView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentCore
import SwiftUI

struct AnywayPaymentElementParameterView: View {
    
    let state: AnywayPayment.UIComponentType.Parameter
    let event: (AnywayPaymentEvent) -> Void

    var body: some View {
        
        Text(String(describing: state))
    }
}

struct AnywayPaymentElementParameterView_Previews: PreviewProvider {
    
    static var previews: some View {
 
        AnywayPaymentElementParameterView(state: .preview, event: { _ in })
    }
}
