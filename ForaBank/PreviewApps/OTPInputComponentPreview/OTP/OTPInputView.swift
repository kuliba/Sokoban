//
//  OTPInputView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct OTPInputView: View {
    
    @ObservedObject private var viewModel: OTPInputViewModel
    
    init(viewModel: OTPInputViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
#warning("replace with ZStack")
        VStack {
            
            HStack {
                
                ForEach(
                    viewModel.state.digitModels,
                    content: DigitModelView.init
                )
                .monospacedDigit()
            }
            
            TextField("sdsds", text: .init(
                get: {
                    let text = viewModel.state.text
                    print(text, "viewModel.state.text")
                    return text
                },
                set: viewModel.edit
            ))
            .keyboardType(.numberPad)
            
            // autofocusTextField()
            .fixedSize()
        }
    }
    
    private func autofocusTextField() -> some View {
        
        AutofocusTextField(
            placeholder: "",
            text: .init(
                get: {
                    let text = viewModel.state.text
                    print(text, "viewModel.state.text")
                    return text
                },
                set: viewModel.edit
            ),
            isFirstResponder: true,
            textColor: .clear,
            backgroundColor: .clear,
            keyboardType: .numberPad
        )
        .accentColor(.clear)
        .tint(.clear)
        .foregroundColor(.clear)
        .textContentType(.oneTimeCode)
        // .disabled(viewModel.state.isInputDisabled)
    }
}

private extension OTPInputState {
    
    var digitModels: [DigitModel] {
        
#warning("move maxLength to init")
        let length = 6
        return text
            .filter(\.isNumber)
            .padding(toLength: length, withPad: " ", startingAt: 0)
            .map { String($0) }
            .enumerated()
            .map {
                
                DigitModel(id: $0.offset, value: $0.element)
            }
    }
}


struct OTPInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OTPInputView(viewModel: .default())
    }
}
