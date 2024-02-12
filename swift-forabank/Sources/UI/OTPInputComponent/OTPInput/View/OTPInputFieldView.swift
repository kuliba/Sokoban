//
//  OTPInputFieldView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

struct OTPInputFieldView: View {
    
    let state: OTPFieldState
    let event: (OTPFieldEvent) -> Void
    
    @State private var isFocused = false
    
    var body: some View {
        
        ZStack {
            
            tabula()
            
            autofocusTextField()
                .fixedSize()
        }
    }
    
    private func tabula() -> some View {
        
        HStack {
            
            ForEach(
                state.digitModels,
                content: DigitModelView.init
            )
        }
    }
    
    private func autofocusTextField() -> some View {
        
        AutofocusTextField(
            placeholder: "",
            text: .init(
                get: { state.text },
                set: { event(.edit($0)) }
            ),
            isFirstResponder: isFocused,
            textColor: .clear,
            backgroundColor: .clear,
            keyboardType: .numberPad
        )
        .accentColor(.clear)
        .foregroundColor(.clear)
        .textContentType(.oneTimeCode)
        .onAppear {
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.1, 
                execute: { isFocused = true }
            )
        }
    }
}

private extension OTPFieldState {
    
    var digitModels: [DigitModel] {
        
        // TODO: move maxLength to init
        let maxLength = 6
        
        return text
            .filter(\.isNumber)
            .padding(toLength: maxLength, withPad: " ", startingAt: 0)
            .map { String($0) }
            .enumerated()
            .map { .init(id: $0.offset, value: $0.element) }
    }
}


struct OTPInputFieldView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        otpInputView(.init())
        otpInputView(.init(text: "1234"))
        otpInputView(.init(text: "123456", isInputComplete: true))
    }
    
    private static func otpInputView(
        _ state: OTPFieldState
    ) -> some View {
        
        OTPInputFieldView(
            state: state,
            event: { _ in }
        )
    }
}
