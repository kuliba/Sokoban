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
        
        otpInputView(.success(()))
        otpInputView(.failure(.connectivityError))
        otpInputView(.failure(.serverError("Server Error Failure")))
    }
    
    private static func otpInputView(
        _ result: OTPInputEffectHandler.SubmitOTPResult
    ) -> some View {
        
        OTPInputView(viewModel: .preview(result))
    }
}

extension OTPInputViewModel {
    
    static func preview(
        _ result: OTPInputEffectHandler.SubmitOTPResult
    ) -> OTPInputViewModel {
        
        .default(submitOTP: { _, completion in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                completion(result)
            }
        })
    }
}

extension OTPInputViewModel {
    
    static func `default`(
        submitOTP: @escaping OTPInputEffectHandler.SubmitOTP,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> OTPInputViewModel {
        
        let reducer = OTPInputReducer()
        let effectHandler = OTPInputEffectHandler(submitOTP: submitOTP)
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
