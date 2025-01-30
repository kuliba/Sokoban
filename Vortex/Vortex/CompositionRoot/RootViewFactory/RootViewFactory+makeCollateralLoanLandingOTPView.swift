//
//  RootViewFactory+makeCollateralLoanLandingOTP.swift
//  Vortex
//
//  Created by Valentin Ozerov on 29.01.2025.
//

import CollateralLoanLandingGetShowcaseUI
import OTPInputComponent
import UIPrimitives

extension RootViewFactory {
 
    func makeCollateralLoanLandingOTPView() -> OTPView {
        
        .init(
            viewModel: makeCollateralLoanLandingOTPViewModel(),
            config: <#T##TimedOTPInputWrapperView<IconView, OTPWarningView>.Config#>,
            iconView: <#T##() -> IconView#>,
            warningView: <#T##() -> OTPWarningView#>
        )
    }
} 

extension RootViewFactory {
    
    typealias ShowcaseFactory = CollateralLoanLandingGetShowcaseViewFactory
    typealias OTPView = ShowcaseFactory.OTPView
    typealias IconView = UIPrimitives.AsyncImage
}
