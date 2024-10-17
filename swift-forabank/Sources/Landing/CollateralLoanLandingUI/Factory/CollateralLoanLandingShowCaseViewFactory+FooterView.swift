//
//  CollateralLoanLandingShowCaseViewFactory+FooterView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseViewFactory {

    func makeFooterView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductFooterView {

            .init(
                config: config,
                theme: CollateralLoanLandingShowCaseTheme.map(model.theme)
            )
    }
}
