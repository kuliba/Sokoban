//
//  CreateDraftCollateralLoanApplicationOTPView.swift
//
//
//  Created by Valentin Ozerov on 29.01.2025.
//

import SwiftUI
import PaymentComponents
import OTPInputComponent

struct CreateDraftCollateralLoanApplicationOTPView: View {
    
    let state: DomainState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory

    var body: some View {

        TimedOTPInputWrapperView(
            viewModel: .init(
                otpText: state.otp,
                timerDuration: config.elements.otp.timerDuration,
                otpLength: config.elements.otp.otpLength,
                resend: { event(.getVerificationCode) },
                observe: { event(.otp($0)) }
            ),
            config: config.elements.otp.view,
            iconView: {
                config.elements.otp.smsIcon
            }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationOTPView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias DomainState = CreateDraftCollateralLoanApplicationDomain.State
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
