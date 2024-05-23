//
//  CodeInputWrapperView.swift
//
//
//  Created by Дмитрий Савушкин on 23.05.2024.
//

import SwiftUI

public struct CodeInputWrapperView: View {
    
    @StateObject private var viewModel: TimedOTPInputViewModel
    let config: CodeInputConfig
    
    public init(
        viewModel: TimedOTPInputViewModel,
        config: CodeInputConfig
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    public var body: some View {
        
        switch viewModel.state.status {
        case .failure(_):
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

struct CodeInputWrapperView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        CodeInputWrapperView(
            viewModel: .init(
                viewModel: .default(
                    initialState: .starting(
                        phoneNumber: .init(""),
                        duration: 60
                    ),
                    initiateOTP: { _ in },
                    submitOTP: { _,_  in })
            ),
            config: .preview
        )
    }
}

private extension CodeInputConfig {
    
    static let preview: Self = .init(
        icon: .init(systemName: "phone"),
        button: .preview,
        digitModel: .preview,
        resend: .preview,
        subtitle: .init(textFont: .body, textColor: .black),
        timer: .init(textFont: .body, textColor: .red),
        title: .init(textFont: .body, textColor: .black)
    )
}
