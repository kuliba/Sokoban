//
//  CodeInputWrapperView.swift
//
//
//  Created by Дмитрий Савушкин on 23.05.2024.
//

import SwiftUI

struct CodeInputWrapperView: View {
    
    @StateObject private var viewModel: TimedOTPInputViewModel
    let config: CodeInputConfig
    
    var body: some View {
        
        switch viewModel.state.status {
        case let .failure(otpFieldFailure):
            CodeInputView(
                state: .incompleteOTP,
                event: viewModel.event(_:),
                config: config
            )
            
        case let .input(input):
            CodeInputView(
                state: input,
                event: viewModel.event(_:),
                config: config
            )
            
        case .validOTP:
            CodeInputView(
                state: .completeOTP,
                event: viewModel.event(_:),
                config: config
            )
        }
    }
    
}

