//
//  CollateralLoanLandingDetailsButton.swift
//  Vortex
//
//  Created by Valentin Ozerov on 19.02.2025.
//

import SwiftUI
import ButtonWithSheet
import CollateralLoanLandingCreateDraftCollateralLoanApplicationUI

struct CollateralLoanLandingDetailsButton: View {
    
    let makeViewModel: MakeOperationDetailInfoViewModel
    let details: DetailCells
    
    var body: some View {
        
        let buttonLabel = { makeSuccessButtonLabel(option: .details) }

        MagicButtonWithSheet(
            buttonLabel: buttonLabel,
            getValue: { $0(details) },
            makeValueView: makeDetailView
        )
    }
}

extension CollateralLoanLandingDetailsButton {
    
    typealias MakeOperationDetailInfoViewModel = ViewComponents.MakeOperationDetailInfoViewModel
    typealias DetailCells = [OperationDetailInfoViewModel.DefaultCellViewModel]
}

extension CollateralLoanLandingDetailsButton {
    
    @ViewBuilder
    func makeDetailView(
        detail: DetailCells,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        OperationDetailInfoView(
            viewModel: makeViewModel(detail, dismiss)
        )
    }
    
    func makeSuccessButtonLabel(
        option: Payments.ParameterSuccessOptionButtons.Option
    ) -> some View {
        
        PaymentsSuccessOptionButtonsView.ButtonView.ButtonLabel(
            title: option.title,
            icon: option.icon
        )
    }

    static let preview = Self(
        makeViewModel: { _,_  in .detailMockData() },
        details: []
    )
}
