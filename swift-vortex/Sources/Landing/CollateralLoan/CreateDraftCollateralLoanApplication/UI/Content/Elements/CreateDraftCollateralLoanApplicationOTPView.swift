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

struct CreateDraftCollateralLoanApplicationOTPView<Confirmation, InformerPayload>: View
    where Confirmation: TimedOTPInputViewModel {

    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    let otpViewModel: TimedOTPInputViewModel

    var body: some View {

        TimedOTPInputWrapperView(
            viewModel: otpViewModel,
            config: config.elements.otp.view,
            iconView: { config.elements.otp.smsIcon },
            warningView: {
                
                OTPWarningView(
                    text: state.warning,
                    config: config.elements.otp.warningText
                )
            }
        )
        .modifier(FrameWithCornerRadiusModifier(config: config))
    }
}

extension CreateDraftCollateralLoanApplicationOTPView {
    
    private struct OTPWarningView: View {
        
        let text: String?
        let config: TextConfig
        
        var body: some View {
            
            text.map {
                
                $0.text(withConfig: config)
            }
        }
    }
}

extension CreateDraftCollateralLoanApplicationOTPView {
    
    typealias Factory = CreateDraftCollateralLoanApplicationFactory
    typealias Config = CreateDraftCollateralLoanApplicationConfig
    typealias Domain = CreateDraftCollateralLoanApplicationDomain
    typealias State = Domain.State<Confirmation, InformerPayload>
    typealias Event = Domain.Event<Confirmation, InformerPayload>
}

// MARK: - Previews

struct CreateDraftCollateralLoanApplicationOTPView_Previews<Confirmation, InformerPayload>: PreviewProvider
    where Confirmation: TimedOTPInputViewModel {
    
    static var previews: some View {
        
        CreateDraftCollateralLoanApplicationOTPView<Confirmation, InformerPayload>(
            state: .init(application: .preview, formatCurrency: { _ in "" }),
            event: {
                print($0)
            },
            config: .default,
            factory: .preview,
            otpViewModel: .preview
        )
    }
}

extension TimedOTPInputViewModel {
    
    static let preview = TimedOTPInputViewModel(
        initialState: .init(phoneNumber: .init(""), status: .input(.completeOTP)),
        reduce: { state, _ in (state, nil) },
        handleEffect: { _,_ in }
    )
}
