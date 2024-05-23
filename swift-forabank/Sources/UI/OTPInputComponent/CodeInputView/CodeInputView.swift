//
//  CodeInputView.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

import SwiftUI
import UIPrimitives

public struct CodeInputView: View {
    
    private let state: OTPInputState.Status.Input
    private let event: (OTPInputEvent) -> Void
    private let config: CodeInputConfig
    
    public init(
        state: OTPInputState.Status.Input,
        event: @escaping (OTPInputEvent) -> Void,
        config: CodeInputConfig
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    private let title = "Введите код"
    
    private var subtitle: String? {
        
        switch state.countdown {
        case let .failure(serviceFailure):
            return serviceFailure.localizedDescription
        default:
            return nil
        }
    }
    
    public var body: some View {
        
        VStack(spacing: 40) {
        
            HStack(spacing: 12) {
                
                config.icon
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(.gray).opacity(0.7)
            
                VStack(spacing: 4) {
                    
                    switch state {
                    case .incompleteOTP, .completeOTP:
                        
                        Text(title)
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.leading)
                        
                        inputField()
                            .padding(.leading, 14)
                        
                    default:
                        inputField()
                            .padding(.leading, 14)
                    }
                }
                
                Spacer()
                
                timerView(
                    state: state.countdown,
                    event: { event(.countdown($0)) }
                )
            }
            .frame(height: 72)
            .padding(.leading, 16)
            .padding(.trailing, 13)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.top, 0)
    }
    
    private func inputField() -> some View {
        
        CodeInputFieldView(
            state: state.otpField,
            event: { event(.otpField($0)) },
            config: config.digitModel
        )
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
            resendButton(action: { event(.prepare) })
            
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

struct CodeInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        codeInputView(.timerCompleted)
            .previewDisplayName("timer Completed")
        codeInputView(.timerRunning)
            .previewDisplayName("timer Running")
        codeInputView(.timerStarting)
            .previewDisplayName("timer Starting")
        codeInputView(.incompleteOTP)
            .previewDisplayName("incomplete OTP")
        codeInputView(.completeOTP)
            .previewDisplayName("complete OTP")
    }
    
    private static func codeInputView(
        _ state: OTPInputState.Status.Input
    ) -> some View {
        
        CodeInputView(
            state: state,
            event: { _ in },
            config: .init(
                icon: .init(systemName: ""),
                button: .preview,
                digitModel: .init(
                    digitConfig: .init(textFont: .body, textColor: .black),
                    rectColor: .black
                ),
                resend: .init(
                    backgroundColor: .black,
                    text: .init(textFont: .callout, textColor: .blue)
                ),
                subtitle: .init(textFont: .body, textColor: .blue),
                timer: .init(textFont: .body, textColor: .green),
                title: .init(textFont: .body, textColor: .black)
            )
        )
        .padding(20)
    }
}
