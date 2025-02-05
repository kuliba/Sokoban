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

    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    let otpViewModel: TimedOTPInputViewModel

    var body: some View {

        TimedOTPInputWrapperView(
            viewModel: otpViewModel,
            config: config.elements.otp.view,
            iconView: { config.elements.otp.smsIcon }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationOTPView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias Confirmation = Domain.Confirmation
    typealias State = Domain.State<Confirmation>
    typealias Event = Domain.Event<Confirmation>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationOTPView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationOTPView(
            state: .init(
                data: .preview,
                confirmation: .preview
            ),
            event: {
                print($0)
            },
            config: .default,
            factory: .preview,
            otpViewModel: .preview
        )
    }
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Data = CreateDraftCollateralLoanApplicationUIData
}
