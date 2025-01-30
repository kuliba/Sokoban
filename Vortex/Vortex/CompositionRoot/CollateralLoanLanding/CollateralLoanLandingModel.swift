//
//  CollateralLoanLandingModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 30.01.2025.
//

import CombineSchedulers
import Foundation
import OTPInputComponent

struct CollateralLoanLandingModel {

    let otpServices: CollateralLoanLandingOTPServices
}

extension CollateralLoanLandingModel {
    
    typealias AnySchedulerOfDispatchQueue = AnySchedulerOf<DispatchQueue>
}
