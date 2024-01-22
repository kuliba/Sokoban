//
//  OTPInputFieldView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct OTPInputFieldView: View {
    
    let state: OTPFieldState
    let event: (OTPFieldEvent) -> Void
    
    @State private var isFocused = false
    
    var body: some View {
#warning("replace with ZStack")
        VStack {
            
            HStack {
                
                ForEach(
                    state.digitModels,
                    content: DigitModelView.init
                )
                .monospacedDigit()
            }
            
            // TextField("sdsds", text: .init(
            //     get: {
            //         let text = viewModel.state.text
            //         print(text, "viewModel.state.text")
            //         return text
            //     },
            //     set: viewModel.edit
            // ))
            // .keyboardType(.numberPad)
            
            autofocusTextField()
                .fixedSize()
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
        .tint(.clear)
        .foregroundColor(.clear)
        .textContentType(.oneTimeCode)
        .onAppear { isFocused = true }
    }
}

private extension OTPFieldState {
    
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

extension OTPFieldViewModel {
    
    static func preview(
        _ result: OTPFieldEffectHandler.SubmitOTPResult
    ) -> OTPFieldViewModel {
        
        .default(submitOTP: { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(result)
            }
        })
    }
}

extension OTPFieldViewModel {
    
    static func `default`(
        submitOTP: @escaping OTPFieldEffectHandler.SubmitOTP,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPFieldViewModel {
        
        let reducer = OTPFieldReducer()
        let effectHandler = OTPFieldEffectHandler(submitOTP: submitOTP)
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
