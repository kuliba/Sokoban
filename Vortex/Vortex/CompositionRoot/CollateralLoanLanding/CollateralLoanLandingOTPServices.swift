//
//  CollateralLoanLandingOTPServices.swift
//  Vortex
//
//  Created by Valentin Ozerov on 30.01.2025.
//

import OTPInputComponent

struct CollateralLoanLandingOTPServices {
    
    let initiateOTP: CountdownEffectHandler.InitiateOTP
    let submitOTP: OTPFieldEffectHandler.SubmitOTP
}

private extension CollateralLoanLandingOTPServices {
    
    init(
        _ httpClient: HTTPClient,
        _ logger: any LoggerAgentProtocol
    ) {
        let composer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        
        self.init(
            initiateOTP: composer.composeFastInitiateOTP(),
            submitOTP: composer.composeFastSubmitOTP()
        )
    }
}
