//
//  CollateralLoanLandingGetShowcaseViewFactory+FooterView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingGetShowcaseViewFactory {

    func makeFooterView(with model: CollateralLoanLandingGetShowcaseData.Product)
        -> CollateralLoanLandingGetShowcaseProductFooterView {

            .init(
                config: config,
                theme: model.theme.map()
            )
    }
}
