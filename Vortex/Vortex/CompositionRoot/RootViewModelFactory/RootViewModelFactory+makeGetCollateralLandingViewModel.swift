//
//  RootViewModelFactory+makeGetCollateralLandingViewModel.swift
//  Vortex
//
//  Created by Valentin Ozerov on 13.01.2025.
//

import CollateralLoanLandingGetCollateralLandingUI

extension RootViewModelFactory {
    
    // MARK: - Content
    
    private func makeContent() -> GetCollateralLandingDomain.Content {
        
        let reducer = GetCollateralLandingDomain.Reducer()
        let effectHandler = GetShowcaseDomain.EffectHandler(load: loadCollateralLoanLanding)
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:dispatch:),
            scheduler: schedulers.main
        )
    }
}
