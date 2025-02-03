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
    
    private let viewModel = OTPViewModel()
        
    var body: some View {

        TimedOTPInputWrapperView(
            viewModel: makeOTPViewModel(),
            config: config.elements.otp.view,
            iconView: {
                config.elements.otp.smsIcon
            }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

private extension CreateDraftCollateralLoanApplicationOTPView {
    
    func makeOTPViewModel() -> TimedOTPInputViewModel {
        
        let otpViewModel = TimedOTPInputViewModel(
            otpText: state.otp,
            timerDuration: config.elements.otp.timerDuration,
            otpLength: config.elements.otp.otpLength,
            resend: { event(.getVerificationCode) },
            observe: { event(.otp($0)) }
        )
        
        viewModel.inputViewModel = otpViewModel
        
        viewModel.cancellable = otpViewModel.$state
            .sink(receiveValue: {
                if $0.status == .validOTP {
                    event(.otpValidated)
                }
        })
        
        return otpViewModel
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

private final class OTPViewModel {
    
    var cancellable: AnyCancellable?
    var inputViewModel: TimedOTPInputViewModel?
}
