//
//  DefaultCancellableSearchBarView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2023.
//

import SwiftUI
import TextFieldComponent
import SearchBarComponent

struct DefaultCancellableSearchBarView: View {
    
    @ObservedObject private var viewModel: RegularFieldViewModel
    private let textFieldConfig: RegularTextFieldView.TextFieldConfig
    private let buttonsColor: Color
    private let cancel: () -> Void
    
    init(
        viewModel: RegularFieldViewModel,
        textFieldConfig: RegularTextFieldView.TextFieldConfig,
        buttonsColor: Color = .mainColorsGray,
        cancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.textFieldConfig = textFieldConfig
        self.buttonsColor = buttonsColor
        self.cancel = cancel
    }
    
    var body: some View {
        
        CancellableSearchBarView(
            viewModel: viewModel,
            textFieldConfig: textFieldConfig,
            clearButtonLabel: clearButtonLabel,
            cancelButton: cancelButton
        )
        .wrappedInRoundedRectangle(strokeColor: .bordersDivider)
    }
    
    private func clearButtonLabel() -> some View {
        
        Image.ic24Close
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(buttonsColor)
    }
    
    @ViewBuilder
    private func cancelButton() -> some View {
        
        if case .editing = viewModel.state {
            
            Button(action: cancel) {
                Text("Отмена")
                    .foregroundColor(buttonsColor)
                    .font(.system(size: 14))
            }
        }
    }
}

extension View {
    
    func wrappedInRoundedRectangle(strokeColor: Color) -> some View {
        
        self
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(.leading, 14)
            .padding(.trailing, 15)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
}

struct DefaultCancellableSearchBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            defaultCancellableSearchBarView(initialPhoneNumber: nil)
            defaultCancellableSearchBarView(initialPhoneNumber: "")
            defaultCancellableSearchBarView(initialPhoneNumber: "123")
        }
    }
    
    private static func defaultCancellableSearchBarView(
        initialPhoneNumber: String?
    ) -> some View {
        
        DefaultCancellableSearchBarView(
            viewModel: TextFieldFactory.makePhoneKitTextField(
                initialPhoneNumber: initialPhoneNumber,
                placeholderText: "Enter phone number",
                filterSymbols: [],
                countryCodeReplaces: []
            ),
            textFieldConfig: .black16,
            buttonsColor: .orange,
            cancel: {}
        )
        .padding()
    }
}
