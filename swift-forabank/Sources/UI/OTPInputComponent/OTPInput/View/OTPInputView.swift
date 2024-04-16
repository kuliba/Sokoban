//
//  OTPInputView.swift
//  OTPInputComponentPreview
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI
import UIPrimitives

public struct OTPInputView: View {
    
    private let state: OTPInputState.Status.Input
    private let phoneNumber: String
    private let event: (OTPInputEvent) -> Void
    private let config: OTPInputConfig
    
    public init(
        state: OTPInputState.Status.Input,
        phoneNumber: String,
        event: @escaping (OTPInputEvent) -> Void,
        config: OTPInputConfig
    ) {
        self.state = state
        self.phoneNumber = phoneNumber
        self.event = event
        self.config = config
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
            
            title.text(withConfig: config.title)
            
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
    
    private func inputField() -> some View {
        
        OTPInputFieldView(
            state: state.otpField,
            event: { event(.otpField($0)) },
            config: config.digitModel
        )
    }
    
    private func descriptionView() -> some View {
        
        subtitle.text(withConfig: config.subtitle)
            .multilineTextAlignment(.center)
            .fixedSize()
    }
    
    @ViewBuilder
    private func timerView(
        state: CountdownState,
        event: @escaping (CountdownEvent) -> Void
    ) -> some View {
        
        switch state {
        case .completed:
            resendButton(action: { event(.prepare) })
            
        case let .failure(countdownFailure):
            // Alert should dismiss view
            EmptyView()
            
        case let .running(remaining: remaining):
            remainingTime(remaining).text(withConfig: config.timer)
            
        case let .starting(duration):
            remainingTime(duration).text(withConfig: config.timer)
        }
    }
    
    private func resendButton(
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            ZStack {
                
                config.resend.backgroundColor
                
                "Отправить повторно".text(withConfig: config.resend.text)
                    .padding(.horizontal)
            }
            .frame(height: 24)
            .fixedSize()
            .clipShape(RoundedRectangle(cornerRadius: 90))
        }
    }
    
    private func confirmButton() -> some View {
        
        Button(action: confirmButtonAction) {
            
            ZStack {
                
                confirmButtonBackgroundColor()
                
                "Подтвердить".text(withConfig: confirmButtonTextConfig())
            }
            .frame(height: config.button.buttonHeight)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
        .accentColor(state.isConfirmButtonActive ? .red : .gray.opacity(0.4))
    }
    
    private func confirmButtonAction() {
        
        if state.isConfirmButtonActive {
            
            event(.otpField(.confirmOTP))
        }
    }
    
    private func confirmButtonBackgroundColor() -> some View {
        
        state.isConfirmButtonActive
        ? config.button.active.backgroundColor
        : config.button.inactive.backgroundColor
    }
    
    private func confirmButtonTextConfig() -> TextConfig {
        
        state.isConfirmButtonActive
        ? config.button.active.text
        : config.button.active.text
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
        .accentColor(.clear)
        .foregroundColor(.clear)
        .textContentType(.oneTimeCode)
    }
    
    private func remainingTime(_ remaining: Int) -> String {
        
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private extension OTPInputState.Status.Input {
    
    var isTimerCompleted: Bool {
        
        countdown == .completed
    }
    
    var isOTPInputComplete: Bool {
        
        otpField.isInputComplete
    }
    
    var isConfirmButtonActive: Bool {
        
        isOTPInputComplete && otpField.status != .inflight
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
        _ state: OTPInputState.Status.Input
    ) -> some View {
        
        OTPInputView(
            state: state,
            phoneNumber: "+7 ... ... 54 15",
            event: { _ in },
            config: .preview
        )
    }
}
