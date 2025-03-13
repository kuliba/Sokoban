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
import PDFKit
import RemoteServices
import SwiftUI
import UIPrimitives

extension ViewComponents {
    
    typealias MakeOperationDetailInfoViewModel = (
        [OperationDetailInfoViewModel.DefaultCellViewModel],
        @escaping () -> Void
    ) -> OperationDetailInfoViewModel
    
    func makeCollateralLoanWrapperView(
        binder: GetCollateralLandingDomain.Binder,
        makeOperationDetailInfoViewModel: @escaping MakeOperationDetailInfoViewModel,
        goToMain: @escaping () -> Void,
        getPDFDocument: @escaping GetPDFDocument,
        formatCurrency: @escaping FormatCurrency
    ) -> CollateralLoanLandingWrapperView {
        
        .init(
            binder: binder,
            config: .default,
            factory: makeCollateralLoanLandingFactory(
                formatCurrency: formatCurrency
            ),
            goToMain: goToMain,
            makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel,
            getPDFDocument: getPDFDocument
        )
    }
    
    func makeCollateralLoanShowcaseWrapperView(
        makeOperationDetailInfoViewModel: @escaping MakeOperationDetailInfoViewModel,
        binder: GetShowcaseDomain.Binder,
        goToMain: @escaping () -> Void,
        getPDFDocument: @escaping GetPDFDocument,
        formatCurrency: @escaping FormatCurrency
    ) -> CollateralLoanShowcaseWrapperView {
        
        .init(
            binder: binder,
            factory: makeCollateralLoanLandingFactory(
                formatCurrency: formatCurrency
            ),
            config: .default,
            goToMain: goToMain,
            makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel,
            getPDFDocument: getPDFDocument
        )
    }
    
    func makeCollateralLoanLandingFactory(
        formatCurrency: @escaping FormatCurrency
    ) -> CollateralLoanLandingFactory {

        .init(
            makeImageViewWithMD5Hash: { makeIconView(md5Hash: $0) },
            makeImageViewWithURL: { makeGeneralIconView(.image($0.addingPercentEncoding())) },
            formatCurrency: formatCurrency
        )
    }

    typealias GetPDFDocumentCompletion = (PDFDocument?) -> Void
    typealias GetPDFDocument = (
        RemoteServices.RequestFactory.GetConsentsPayload,
        @escaping GetPDFDocumentCompletion
    ) -> Void
    typealias MakeDetailsViewModel
        = CreateDraftCollateralLoanApplicationWrapperView.MakeOperationDetailInfoViewModel
    typealias FormatCurrency = (UInt) -> String?
}
