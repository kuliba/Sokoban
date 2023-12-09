//
//  AmountView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct AmountView: View {
    
    let amount: SberQRConfirmPaymentState.Amount
    let event: (Decimal) -> Void
    let pay: () -> Void
    
    var body: some View {
        
        HStack {
            
            TextField(
                "amount",
                text: .init(
                    get: { "\(amount.value)" },
                    set: {
                        guard let amount = Decimal(string: $0)
                        else { return }
                        
                        event(amount)
                    }
                )
            )
            .font(.title.bold())
            
            Button("Pay", action: pay)
                .font(.headline.bold())
                .padding()
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.red)
                )
        }
    }
}

// MARK: - Previews

struct AmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AmountView(amount: .preview, event: { _ in }, pay: {})
    }
}
