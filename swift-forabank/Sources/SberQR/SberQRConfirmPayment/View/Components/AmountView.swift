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
    
    let config: AmountConfig
    
    private let buttonSize = CGSize(width: 114, height: 40)
    private let frameInsets = EdgeInsets(top: 4, leading: 20, bottom: 16, trailing: 19)
    
    var body: some View {
        
        HStack(spacing: 24) {
            
            amountView()
            buttonView()
        }
        .padding(frameInsets)
        .background(config.backgroundColor.ignoresSafeArea())
    }
    
    private func amountView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            text(amount.title, config: config.title)
            textField()
            Divider().background(config.dividerColor)
                .padding(.top, 4)
        }
    }
    
    #warning("add currency to text field")
    private func textField() -> some View {
        
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
        .foregroundColor(config.amount.textColor)
        .font(config.amount.textFont)
    }
        
    private func buttonView() -> some View {
        
        ZStack {
            
            config.button.active.backgroundColor
                .frame(buttonSize)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            #warning("add button state")
            Button(action: pay) {
                
                text(amount.button.title, config: config.button.active.text)
            }
        }
    }
    
    private func text(
        _ text: String,
        config: TextConfig
    ) -> some View {
        
        Text(text)
            .font(config.textFont)
            .foregroundColor(config.textColor)
    }
}

// MARK: - Previews

struct AmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AmountView(
            amount: .preview,
            event: { _ in },
            pay: {},
            config: .default
        )
    }
}
