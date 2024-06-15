//
//  TimedOTPInputWrapperView.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SwiftUI

public struct TimedOTPInputWrapperView: View {
    
    @ObservedObject private var viewModel: TimedOTPInputViewModel
    private let config: OTPInputConfig
    
    public init(
        viewModel: TimedOTPInputViewModel,
        config: OTPInputConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    public var body: some View {
        
        switch viewModel.state.status {
        case .failure:
            EmptyView()
            
        case let .input(input):
            OTPInputView(
                state: input,
                phoneNumber: viewModel.state.phoneNumber.rawValue,
                event: viewModel.event(_:),
                config: config
            )
            
        case .validOTP:
            EmptyView()
        }
    }
}

#Preview {
    TimedOTPInputWrapperView(
        viewModel: .init(initiateOTP: { _ in }, submitOTP: { _,_ in }),
        config: .preview
    )
}
