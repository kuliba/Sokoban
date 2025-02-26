//
//  ViewComponents+collateralLoanLanding.swift
//  Vortex
//
//  Created by Valentin Ozerov on 26.02.2025.
//

import Foundation
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI

extension ViewComponents {
    
    func makeCollateralLoanWrapperView(
        binder: GetCollateralLandingDomain.Binder,
        getPDFDocument: @escaping CollateralLoanLandingGetShowcaseViewFactory.GetPDFDocument,
        goToMain: @escaping () -> Void
    ) -> CollateralLoanLandingWrapperView {
        
        .init(
            binder: binder,
            factory: makeGetCollateralLandingFactory(getPDFDocument),
            viewModelFactory: makeCollateralLoanLandingViewModelFactory(),
            goToMain: goToMain
        )
    }
    
    func makeCollateralLoanShowcaseWrapperView(
        binder: GetShowcaseDomain.Binder,
        getPDFDocument: @escaping CollateralLoanLandingGetShowcaseViewFactory.GetPDFDocument,
        goToMain: @escaping () -> Void
    ) -> CollateralLoanShowcaseWrapperView {
        
        .init(
            binder: binder,
            factory: makeCollateralLoanLandingGetShowcaseViewFactory(getPDFDocument),
            viewModelFactory: makeCollateralLoanLandingViewModelFactory(),
            goToMain: goToMain
        )
    }
}
