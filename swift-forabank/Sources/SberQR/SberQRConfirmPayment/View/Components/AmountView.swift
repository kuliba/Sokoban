//
//  AmountView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import TextFieldComponent
import SwiftUI

struct AmountView: View {
    
    typealias Amount = SberQRConfirmPaymentState.EditableAmount.Amount
    
    @StateObject private var textFieldModel: DecimalTextFieldViewModel
    
    let amount: Amount
    let event: (Decimal) -> Void
    let pay: () -> Void
    
    let config: AmountConfig
    
    private let getDecimal: (TextFieldState) -> Decimal
    
    init(
        amount: Amount,
        event: @escaping (Decimal) -> Void,
        pay: @escaping () -> Void,
        currencySymbol: String,
        config: AmountConfig
    ) {
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol
        )
        let textField = DecimalTextFieldViewModel.decimal(
            formatter: formatter
        )
        
        self._textFieldModel = .init(wrappedValue: textField)
        self.getDecimal = formatter.getDecimal
        self.amount = amount
        self.event = event
        self.pay = pay
        self.config = config
    }
    
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
    
    private func textField() -> some View {
        
        TextFieldView(
            viewModel: textFieldModel,
            textFieldConfig: .init(
                font: .boldSystemFont(ofSize: 24),
                textColor: config.amount.textColor,
                tintColor: .accentColor,
                backgroundColor: .clear,
                placeholderColor: .clear
            )
        )
        .onReceive(textFieldModel.$state.map(getDecimal), perform: event)
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
            currencySymbol: "$",
            config: .default
        )
    }
}
