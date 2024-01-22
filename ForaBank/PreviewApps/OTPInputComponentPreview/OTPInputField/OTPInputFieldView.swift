//
//  OTPInputFieldView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct OTPInputFieldView: View {
    
    @ObservedObject private var viewModel: OTPFieldViewModel
    
    init(viewModel: OTPFieldViewModel) {
        
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
                get: { viewModel.state.text },
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
        
        otpInputView(.success(()))
        otpInputView(.failure(.connectivityError))
        otpInputView(.failure(.serverError("Server Error Failure")))
    }
    
    private static func otpInputView(
        _ result: OTPFieldEffectHandler.SubmitOTPResult
    ) -> some View {
        
        OTPInputFieldView(viewModel: .preview(result))
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
