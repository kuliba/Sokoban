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
    
    let viewModel: OperationDetailInfoViewModel
    let payload: Payload
    
    var body: some View {
        
        let buttonLabel = { makeSuccessButtonLabel(option: .details) }

        MagicButtonWithSheet(
            buttonLabel: buttonLabel,
            getValue: { $0(payload) },
            makeValueView: makeDetailView
        )
    }
}

extension CollateralLoanLandingDetailsButton {
    
    typealias Payload = CollateralLandingApplicationSaveConsentsResult
}

extension CollateralLoanLandingDetailsButton {
    
    @ViewBuilder
    func makeDetailView(
        detail: Payload,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        OperationDetailInfoView(viewModel: viewModel)
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
        viewModel: .detailMockData(),
        payload: .preview
    )
}
