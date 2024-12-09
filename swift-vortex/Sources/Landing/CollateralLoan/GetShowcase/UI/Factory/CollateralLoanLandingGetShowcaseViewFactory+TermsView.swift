//
//  CollateralLoanLandingGetShowcaseViewFactory+TermsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingGetShowcaseViewFactory {

    func makeTermsView(with model: CollateralLoanLandingGetShowcaseData.Product)
        -> CollateralLoanLandingGetShowcaseProductTermsView {

            .init(
                params: model.keyMarketingParams,
                config: config,
                theme: model.theme.map()
            )
    }
}
