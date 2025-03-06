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
        model: Model,
        binder: GetCollateralLandingDomain.Binder,
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
            makeOperationDetailInfoViewModel: {
                
                makeOperationDetailInfoViewModel(
                    model: model,
                    payload: $0,
                    formatCurrency: formatCurrency
                )
            }
        )
    }
    
    func makeCollateralLoanShowcaseWrapperView(
        model: Model,
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
            makeOperationDetailInfoViewModel: {
                
                makeOperationDetailInfoViewModel(
                    model: model,
                    payload: $0,
                    formatCurrency: formatCurrency
                )
            }
        )
    }
    
    func makeCollateralLoanLandingFactory(
        getPDFDocument: @escaping GetPDFDocument,
        formatCurrency: @escaping FormatCurrency
    ) -> CollateralLoanLandingFactory {

        .init(
            makeImageViewWithMD5Hash: { makeGeneralIconView(md5Hash: $0) },
            makeImageViewWithURL: { makeIconView(.image($0.addingPercentEncoding())) },
            getPDFDocument: getPDFDocument,
            formatCurrency: formatCurrency
        )
    }
    
    func makeOperationDetailInfoViewModel(
        model: Model,
        payload: CollateralLandingApplicationSaveConsentsResult,
        formatCurrency: @escaping FormatCurrency
    ) -> OperationDetailInfoViewModel {
        
        OperationDetailInfoViewModel(
            model: model,
            logo: nil,
            cells: payload.makeCells(
                config: .default,
                makeImageViewWithMD5Hash: { makeGeneralIconView(md5Hash: $0) },
                formatCurrency: formatCurrency
            ),
            dismissAction: {}
        )
    }

    typealias GetPDFDocument = GetCollateralLandingFactory.GetPDFDocument
    typealias MakeDetailsViewModel = CreateDraftCollateralLoanApplicationWrapperView.MakeOperationDetailInfoViewModel
    typealias FormatCurrency = (UInt) -> String?
}
