//
//  CollateralLoanLandingShowCaseViewFactory+TermsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseViewFactory {

    func makeTermsView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductTermsView {

            .init(
                params: model.keyMarketingParams,
                config: config,
                theme: model.theme.map()
            )
    }
}
