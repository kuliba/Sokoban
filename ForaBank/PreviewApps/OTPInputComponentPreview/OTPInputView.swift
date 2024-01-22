//
//  OTPInputView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI

struct OTPInputView: View {
    
    @State var isTimerCompleted: Bool = false
    @State var isOTPInputCompleted: Bool = false
    
    let title = "Введите код из сообщения"
    let phoneNumber = "+7 ... ... 54 15"
    
    var subtitle: String {
    
        if isTimerCompleted {
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
        .overlay(alignment: .top, content: settingsView)
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
        
        Text(isTimerCompleted ? "кнопка запросить": "00:23")
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
        .tint(isOTPInputCompleted ? .red : .gray.opacity(0.4))
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

    private func settingsView() -> some View {
        
        HStack {
            
            Toggle("is Timer Completed", isOn: $isTimerCompleted)
            Toggle("is OTP Input Completed", isOn: $isOTPInputCompleted)
        }
        .padding()
    }
}

struct OTPInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        otpInputView(
            isTimerCompleted: false,
            isOTPInputCompleted: false
        )
        otpInputView(
            isTimerCompleted: true,
            isOTPInputCompleted: false
        )
        otpInputView(
            isTimerCompleted: false,
            isOTPInputCompleted: true
        )
        otpInputView(
            isTimerCompleted: true,
            isOTPInputCompleted: true
        )
    }
    
    private static func otpInputView(
        isTimerCompleted: Bool,
        isOTPInputCompleted: Bool
    ) -> some View {
 
        OTPInputView(
            isTimerCompleted: isTimerCompleted,
            isOTPInputCompleted: isOTPInputCompleted
        )
    }
}

