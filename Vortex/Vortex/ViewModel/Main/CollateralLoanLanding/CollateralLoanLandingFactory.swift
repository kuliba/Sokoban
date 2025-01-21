//
//  CollateralLoanLandingFactory.swift
//  Vortex
//
//  Created by Valentin Ozerov on 20.01.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

struct CollateralLoanLandingFactory {
    
    let makeCollateralLoanLandingSuccessViewModel: MakeCollateralLoanLandingSuccessViewModel
    
    typealias MakeCollateralLoanLandingSuccessViewModel
        = (CollateralLoanLandingResponse) -> PaymentsSuccessViewModel
}

extension CollateralLoanLandingFactory {
    
    static let preview = Self(
        makeCollateralLoanLandingSuccessViewModel: { _ in
            .previewMobileConnectionOk
        }
    )
}
