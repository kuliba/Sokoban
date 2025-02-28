//
//  ViewComponents+collateralLoanLanding.swift
//  Vortex
//
//  Created by Valentin Ozerov on 26.02.2025.
//

import DropDownTextListComponent
import Foundation
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI
import SwiftUI

extension ViewComponents {
    
    func makeCollateralLoanWrapperView(
        binder: GetCollateralLandingDomain.Binder,
        getPDFDocument: @escaping GetPDFDocument,
        goToMain: @escaping () -> Void,
        makeOperationDetailInfoViewModel: @escaping MakeDetailsViewModel,
        makeCollateralLoanLandingFactory: @escaping MakeCollateralLoanLandingFactory
    ) -> CollateralLoanLandingWrapperView {
        
        .init(
            binder: binder,
            config: .default,
            factory: makeCollateralLoanLandingFactory(),
            goToMain: goToMain,
            makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel
        )
    }
    
    func makeCollateralLoanShowcaseWrapperView(
        binder: GetShowcaseDomain.Binder,
        goToMain: @escaping () -> Void,
        getPDFDocument: @escaping GetPDFDocument,
        makeOperationDetailInfoViewModel: @escaping MakeDetailsViewModel,
        makeCollateralLoanLandingFactory: @escaping MakeCollateralLoanLandingFactory
    ) -> CollateralLoanShowcaseWrapperView {
        
        .init(
            binder: binder,
            factory: makeCollateralLoanLandingFactory(),
            config: .default,
            goToMain: goToMain,
            makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel
        )
    }
    
    typealias GetPDFDocument = GetCollateralLandingFactory.GetPDFDocument
    typealias MakeDetailsViewModel = CreateDraftCollateralLoanApplicationWrapperView.MakeOperationDetailInfoViewModel
    typealias MakeCollateralLoanLandingFactory = () -> CollateralLoanLandingFactory
}
