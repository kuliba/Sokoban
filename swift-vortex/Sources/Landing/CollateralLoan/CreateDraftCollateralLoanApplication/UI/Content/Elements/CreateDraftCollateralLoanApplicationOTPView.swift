//
//  CreateDraftCollateralLoanApplicationOTPView.swift
//
//
//  Created by Valentin Ozerov on 29.01.2025.
//

import Combine
import OTPInputComponent
import PaymentComponents
import SwiftUI

struct CreateDraftCollateralLoanApplicationOTPView: View {

    var state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
    }
    
    var body: some View {

        TimedOTPInputWrapperView(
            viewModel: state.makeTimedOTPInputViewModel(
                timerDuration: config.elements.otp.timerDuration,
                otpLength: config.elements.otp.otpLength,
                event: event
            ),
            config: config.elements.otp.view,
            iconView: { config.elements.otp.smsIcon }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationOTPView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias State = CreateDraftCollateralLoanApplicationDomain.State
    typealias Event = CreateDraftCollateralLoanApplicationDomain.Event
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationOTPView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationOTPView(
            state: .correntParametersPreview,
            event: { print($0) },
            config: .default,
            factory: .preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
