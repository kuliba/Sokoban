//
//  CollateralLoanLandingShowCaseViewFactory+FooterView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseViewFactory {

    func makeFooterView(with model: CollateralLoanLandingShowCaseData.Product)
        -> CollateralLoanLandingShowCaseProductFooterView {

            .init(
                config: config,
                theme: model.theme.map()
            )
    }
}
