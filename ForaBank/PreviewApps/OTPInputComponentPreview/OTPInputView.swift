//
//  OTPInputView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import OTPInputComponent
import SwiftUI

public struct OTPInputView: View {
    
    private let state: OTPInputState.Input
    private let phoneNumber: String
    private let event: (OTPInputEvent) -> Void
    
    public init(
        state: OTPInputState.Input,
        phoneNumber: String,
        event: @escaping (OTPInputEvent) -> Void
    ) {
        self.state = state
        self.phoneNumber = phoneNumber
        self.event = event
    }
    
    private let title = "Введите код из сообщения"
    
    private var subtitle: String {
        
        if state.isTimerCompleted {
            return "Код отправлен на \(phoneNumber)"
        } else {
            return "Код отправлен на \(phoneNumber)\nЗапросить повторно можно через"
        }
    }
    
    public var body: some View {
        
        VStack(spacing: 40) {
            
            titleView()
            
            ZStack(alignment: .top) {
                
                Color.clear
                
                VStack(spacing: 32) {
                    
                    inputField()
                    
                    descriptionView()
                    
                    timerView(
                        state: state.countdown,
                        event: { event(.countdown($0)) }
                    )
                }
            }
            
            confirmButton()
        }
        .padding(.top, 0)
    }
    
    private func titleView() -> some View {
        
        Text(title)
            .font(.headline.bold())
    }
    
    private func inputField() -> some View {
        
        OTPInputFieldView(
            state: state.otpField,
            event: { event(.otpField($0)) }
        )
    }
    
    @ViewBuilder
    private func timerView(
        state: CountdownState,
        event: @escaping (CountdownEvent) -> Void
    ) -> some View {
        
        switch state {
        case .completed:
            Button("resend") { event(.prepare) }
                .buttonStyle(.bordered)
            
        case let .failure(countdownFailure):
            Text("Alert: \(String(describing: countdownFailure))")
                .foregroundStyle(.red)
            
        case let .running(remaining: remaining):
            Text(remainingTime(remaining))
                .monospacedDigit()
                .foregroundStyle(.secondary)
            
        case let .starting(duration):
            Text(remainingTime(duration))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
    
    private func confirmButton() -> some View {
        
        Button {
            event(.otpField(.confirmOTP))
            
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
        // .disabled(state.isInputDisabled)
    }
    
    private func remainingTime(_ remaining: Int) -> String {
        
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
            .previewDisplayName("timer Completed")
        otpInputView(.timerFailure)
            .previewDisplayName("timer Failure")
        otpInputView(.timerRunning)
            .previewDisplayName("timer Running")
        otpInputView(.timerStarting)
            .previewDisplayName("timer Starting")
        otpInputView(.incompleteOTP)
            .previewDisplayName("incomplete OTP")
        otpInputView(.completeOTP)
            .previewDisplayName("complete OTP")
    }
    
    private static func otpInputView(
        _ state: OTPInputState.Input
    ) -> some View {
        
        OTPInputView(
            state: state,
            phoneNumber: "+7 ... ... 54 15",
            event: { _ in }
        )
    }
}
