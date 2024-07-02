//
//  TimedOTPInputView.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SharedConfigs
import SwiftUI

struct TimedOTPInputView<IconView, WarningView>: View
where IconView: View,
      WarningView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let iconView: () -> IconView
    let warningView: () -> WarningView
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            iconView()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                
                config.title.text.text(withConfig: config.title.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    
                    textField(
                        getText: { state.otpField.text },
                        setText: { event(.edit($0)) }
                    )
                    .apply(config: config.otp)
                    
                    timer(
                        state: state.countdown,
                        resend: { event(.resend) }
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                warningView()
            }
        }
    }
}

extension TimedOTPInputView {
    
    typealias State = OTPInputState.Status.Input
    typealias Event = InputViewEvent
    typealias Config = TimedOTPInputViewConfig
}

private extension TimedOTPInputView {
    
    func textField(
        getText: @escaping () -> String,
        setText: @escaping (String) -> Void
    ) -> some View {
        
        TextField("", text: .init(get: getText, set: setText))
    }
    
    @ViewBuilder
    func timer(
        state: CountdownState,
        resend: @escaping () -> Void
    ) -> some View {
        
        switch state {
        case .completed:
            resendButton(
                action: resend,
                with: config.resend
            )
            
        case .failure:
            EmptyView()
            
        case let .running(remaining: seconds),
            let .starting(duration: seconds):
            timerLabel(
                text: remainingTime(seconds),
                backgroundColor: config.timer.backgroundColor,
                config: config.timer.config
            )
        }
    }
    
    func resendButton(
        action: @escaping () -> Void,
        with config: Config.ResendConfig
    ) -> some View {
        
        Button(action: action) {
            
            timerLabel(
                text: config.text,
                backgroundColor: config.backgroundColor,
                config: config.config
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func timerLabel(
        text: String,
        backgroundColor: Color,
        config: TextConfig
    ) -> some View {
        
        text
            .text(withConfig: config)
            .lineLimit(1)
            .padding(4)
            .padding(.horizontal, 4)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func remainingTime(_ remaining: Int) -> String {
        
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimedOTPInputView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        List {
            
            view(.completeOTP)
            view(.completeOTP) {
                
                Text("This is a warning.")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            view(.incompleteOTP)
            view(.timerFailure)
            view(.timerRunning)
            view(.timerRunning) {
                
                Text("This is a warning.")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            view(.timerStarting)
            view(.timerCompleted)
        }
        .listStyle(.plain)
    }
    
    private static func view<WarningView: View>(
        _ state: TimedOTPInputView.State,
        warningView: @escaping () -> WarningView = EmptyView.init
    ) -> some View {
        
        TimedOTPInputView(
            state: state,
            event: { print($0) },
            config: .preview,
            iconView: {
                
                Image(systemName: "square")
                    .resizable()
                    .background(Color.red.opacity(0.1))
            },
            warningView: warningView
        )
    }
}

extension TimedOTPInputViewConfig {
    
    static let preview: Self = .init(
        otp: .init(
            textFont: .headline,
            textColor: .orange
        ),
        resend: .init(
            text: "Отправить повторно",
            backgroundColor: Color.blue.opacity(0.1),
            config: .init(
                textFont: .caption,
                textColor: .blue
            )
        ),
        timer: .init(
            backgroundColor: Color.pink,
            config: .init(
                textFont: .subheadline.bold(),
                textColor: .yellow
            )
        ),
        title: .init(
            text: "Введите код",
            config: .init(
                textFont: .subheadline,
                textColor: .green
            )
        )
    )
}
