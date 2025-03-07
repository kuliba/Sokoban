//
//  ViewComponents+collateralLoanLanding.swift
//  Vortex
//
//  Created by Valentin Ozerov on 26.02.2025.
//

import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI
import CollateralLoanLandingGetCollateralLandingUI
import CollateralLoanLandingGetShowcaseUI
import DropDownTextListComponent
import Foundation
import SwiftUI
import UIPrimitives

extension ViewComponents {
    
    func makeCollateralLoanWrapperView(
        binder: GetCollateralLandingDomain.Binder,
        operationDetailInfoViewModel: OperationDetailInfoViewModel,
        goToMain: @escaping () -> Void,
        getPDFDocument: @escaping GetPDFDocument,
        formatCurrency: @escaping FormatCurrency
    ) -> CollateralLoanLandingWrapperView {
        
        .init(
            binder: binder,
            config: .default,
            factory: makeCollateralLoanLandingFactory(
                getPDFDocument: getPDFDocument,
                formatCurrency: formatCurrency
            ),
            goToMain: goToMain,
            operationDetailInfoViewModel: operationDetailInfoViewModel
        )
    }
    
    func makeCollateralLoanShowcaseWrapperView(
        operationDetailInfoViewModel: OperationDetailInfoViewModel,
        binder: GetShowcaseDomain.Binder,
        goToMain: @escaping () -> Void,
        getPDFDocument: @escaping GetPDFDocument,
        formatCurrency: @escaping FormatCurrency
    ) -> CollateralLoanShowcaseWrapperView {
        
        .init(
            binder: binder,
            factory: makeCollateralLoanLandingFactory(
                getPDFDocument: getPDFDocument,
                formatCurrency: formatCurrency
            ),
            config: .default,
            goToMain: goToMain,
            operationDetailInfoViewModel: operationDetailInfoViewModel
        )
    }
    
    func makeCollateralLoanLandingFactory(
        getPDFDocument: @escaping GetPDFDocument,
        formatCurrency: @escaping FormatCurrency
    ) -> CollateralLoanLandingFactory {

        .init(
            makeImageViewWithMD5Hash: { makeIconView(md5Hash: $0) },
            makeImageViewWithURL: { makeGeneralIconView(.image($0.addingPercentEncoding())) },
            getPDFDocument: getPDFDocument,
            formatCurrency: formatCurrency
        )
    }

    typealias GetPDFDocument = GetCollateralLandingFactory.GetPDFDocument
    typealias MakeDetailsViewModel = CreateDraftCollateralLoanApplicationWrapperView.MakeOperationDetailInfoViewModel
    typealias FormatCurrency = (UInt) -> String?
}
