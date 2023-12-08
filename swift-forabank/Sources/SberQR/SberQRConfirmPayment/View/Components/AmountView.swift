//
//  AmountView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct AmountView: View {
    
    let amount: SberQRConfirmPaymentState.Amount
    
    var body: some View {
        Text("AmountView")
    }
}

// MARK: - Previews

struct AmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AmountView(amount: .preview)
    }
}
