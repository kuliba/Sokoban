//
//  AmountView.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import ButtonComponent
import SharedConfigs
import TextFieldComponent
import SwiftUI

public struct AmountView: View {
    
    @StateObject private var textFieldModel: DecimalTextFieldViewModel
    
    let amount: Amount
    let event: (AmountEvent) -> Void
    
    let config: AmountConfig
    
    private let getDecimal: (TextFieldState) -> Decimal
    
    public init(
        amount: Amount,
        event: @escaping (AmountEvent) -> Void,
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
        self.config = config
    }
    
    private let buttonSize = CGSize(width: 114, height: 40)
    private let frameInsets = EdgeInsets(top: 4, leading: 20, bottom: 16, trailing: 19)
    
    public var body: some View {
        
        HStack(spacing: 24) {
            
            amountView()
            buttonView()
        }
        .padding(frameInsets)
        .background(config.backgroundColor.ignoresSafeArea())
    }
    
    private func amountView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            amount.title.text(withConfig: config.title)
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
        .onReceive(textFieldModel.$state.map(getDecimal)) { event(.edit($0)) }
    }
    
    @ViewBuilder
    private func buttonView() -> some View {
        
        if amount.button.isEnabled {
            
            Button {
                
                textFieldModel.finishEditing()
                event(.pay)
            } label: {
                buttonLabel(config: config.button.active)
            }
            
        } else {
            
            buttonLabel(config: config.button.inactive)
        }
    }

    private func buttonLabel(
        config: ButtonStateConfig
    ) -> some View {
        
        ZStack {
            
            config.backgroundColor
                .frame(buttonSize)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            amount.button.title.text(withConfig: config.text)
        }
    }
}

// MARK: - Previews

struct AmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            amountView(amount: .preview)
            amountView(amount: .disabled)
        }
    }
    
    private static func amountView(
        amount: Amount
    ) -> some View {
        
        AmountView(
            amount: amount,
            event: { _ in },
            pay: {},
            currencySymbol: "$",
            config: .preview
        )
    }
}
