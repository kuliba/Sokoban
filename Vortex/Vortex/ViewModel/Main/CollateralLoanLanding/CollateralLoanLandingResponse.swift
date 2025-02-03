//
//  CollateralLoanLandingResponse.swift
//  Vortex
//
//  Created by Valentin Ozerov on 20.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

public struct CollateralLoanLandingResponse: Equatable {
    
    public let parameters: [Parameter]
    
    public init(parameters: [Parameter]) {
        
        self.parameters = parameters
    }
}

public extension CollateralLoanLandingResponse {
    
    enum Parameter: Equatable {
        
        case successText(SuccessText)
    }
}

public extension CollateralLoanLandingResponse.Parameter {
    
    typealias SuccessText = CollateralLoanLandingParameters.SuccessText
}

public typealias CollateralLoanLandingResult = Result<
    CollateralLandingApplicationCreateDraftResult,
    CreateDraftCollateralLoanApplicationDomain.LoadResultFailure
>
