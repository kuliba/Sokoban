//
//  TimedOTPInputWrapperView.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

public struct TimedOTPInputWrapperView<IconView: View>: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let config: Config
    private let iconView: () -> IconView
    
    public init(
        viewModel: ViewModel,
        config: Config,
        iconView: @escaping () -> IconView
    ) {
        self.viewModel = viewModel
        self.config = config
        self.iconView = iconView
    }
    
    public var body: some View {
        
        OTPInputStatusView(
            state: viewModel.state.status
        ) {
            TimedOTPInputView(
                state: $0,
                event: event(_:),
                config: config,
                iconView: iconView
            )
        }
    }
}

public extension TimedOTPInputWrapperView {
    
    typealias ViewModel = TimedOTPInputViewModel
    typealias Config = TimedOTPInputViewConfig
}

private extension TimedOTPInputWrapperView {
    
    func event(
        _ event: InputViewEvent
    ) {
        switch event {
        case .resend:
            viewModel.event(.countdown(.prepare))
            
        case let .edit(text):
            viewModel.event(.otpField(.edit(text)))
        }
    }
}

struct TimedOTPInputWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TimedOTPInputWrapperView(
            viewModel: .init(
                timerDuration: 10,
                initiateOTP: { _ in print("initiateOTP") },
                submitOTP: { otp,_ in print("submitOTP") }
            ),
            config: .preview,
            iconView: {
                
                Image(systemName: "square")
                    .resizable()
                    .background(Color.red.opacity(0.1))
            }
        )
        .padding()
    }
}
