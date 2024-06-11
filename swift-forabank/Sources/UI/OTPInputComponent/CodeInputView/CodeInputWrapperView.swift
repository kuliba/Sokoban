//
//  CodeInputWrapperView.swift
//
//
//  Created by Дмитрий Савушкин on 23.05.2024.
//

import SwiftUI
import RxViewModel

public extension CodeInputWrapperView {
    
    typealias State = CodeInputState
    typealias CodeInputViewModel = RxObservingViewModel<State, OTPInputEvent, OTPInputEffect>
}

public struct CodeInputWrapperView: View {
    
    @StateObject private var viewModel: CodeInputViewModel
    private let config: CodeInputConfig
    
    public init(
        viewModel: CodeInputViewModel,
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
                state: .init(input: input),
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
            viewModel: .default(
                initialState: .init(status: .validOTP),
                observe: { _,_ in},
                initiateOTP: { completion in }
            ),
            config: .preview
        )
    }
}

public extension CodeInputWrapperView.CodeInputViewModel {
    
    static func `default`(
        initialState: CodeInputState,
        timer: TimerProtocol = RealTimer(),
        duration: Int = 60,
        length: Int = 6,
        observe: @escaping (CodeInputState, CodeInputState) -> Void,
        initiateOTP: @escaping CountdownEffectHandler.InitiateOTP,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> CodeInputWrapperView.CodeInputViewModel {
        
        let countdownReducer = CountdownReducer(duration: duration)
        let otpFieldReducer = OTPFieldReducer(length: length)
        let codeInputReducer = CodeInputReducer(
            countdownReduce: countdownReducer.reduce(_:_:),
            otpFieldReduce: otpFieldReducer.reduce(_:_:)
        )
        
        let countdownEffectHandler = CountdownEffectHandler(initiate: initiateOTP)
        let otpFieldEffectHandler = OTPFieldEffectHandler(submitOTP: {_,_ in })
        let otpInputEffectHandler = OTPInputEffectHandler(
            handleCountdownEffect: countdownEffectHandler.handleEffect(_:_:),
            handleOTPFieldEffect: otpFieldEffectHandler.handleEffect(_:_:))
        
        return .init(
            observable: .init(
                initialState: initialState,
                reduce: codeInputReducer.reduce(_:_:),
                handleEffect: otpInputEffectHandler.handleEffect(_:_:),
                scheduler: scheduler
            ),
            observe: observe,
            scheduler: scheduler
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
