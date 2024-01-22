//
//  OTPInputView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

struct OTPInputView: View {
    
    let state: OTPInputState.Input
    let event: (OTPInputEvent) -> Void
    
    let title = "Введите код из сообщения"
    let phoneNumber = "+7 ... ... 54 15"
    
    var subtitle: String {
        
        if state.isTimerCompleted {
            return "Код отправлен на \(phoneNumber)"
        } else {
            return "Код отправлен на \(phoneNumber)\nЗапросить повторно можно через"
        }
    }
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            titleView()
            
            ZStack(alignment: .top) {
                
                Color.clear
                
                VStack(spacing: 32) {
                    
                    inputField()
                    
                    descriptionView()
                    
                    timerView()
                }
            }
            
            confirmButton()
        }
        .padding(.top, 88)
    }
    
    private func titleView() -> some View {
        
        Text(title)
            .font(.headline.bold())
    }
    
    private func inputField() -> some View {
        
        ZStack {
            
            Text("OTP Input Field")
                .font(.largeTitle.bold())
                .foregroundStyle(.secondary)
            
            autofocusTextField()
                .frame(width: 1, height: 1)
                .offset(x: -400)
        }
    }
    
    private func timerView() -> some View {
        
        Text(state.isTimerCompleted ? "кнопка запросить": "00:23")
            .foregroundStyle(.secondary)
    }
    
    private func confirmButton() -> some View {
        
        Button {
            
        } label: {
            Text("Подтвердить")
                .bold()
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .padding(.bottom, 24)
        .tint(state.isOTPInputComplete ? .red : .gray.opacity(0.4))
    }
    
    private func descriptionView() -> some View {
        
        Text(subtitle)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize()
    }
    
    private func autofocusTextField() -> some View {
        
        AutofocusTextField(
            placeholder: "",
            text: .constant(""),
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

private extension OTPInputState.Input {
    
    var isTimerCompleted: Bool {
        
        countdown == .completed
    }
    
    var isOTPInputComplete: Bool {
        
        otpField.isInputComplete
    }
}

struct OTPInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        otpInputView(.timerCompleted)
        otpInputView(.timerStarting)
        otpInputView(.timerRunning)
        otpInputView(.incompleteOTP)
        otpInputView(.completeOTP)
    }
    
    private static func otpInputView(
        _ state: OTPInputState.Input
    ) -> some View {
        
        OTPInputView(state: state, event: { _ in })
    }
}
