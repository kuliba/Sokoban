//
//  CollateralLoanLandingGetShowcaseViewFactory+FooterView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingGetShowcaseViewFactory {

    func makeFooterView(
        with model: CollateralLoanLandingGetShowcaseData.Product,
        event: @escaping (String) -> Void
    )
        -> CollateralLoanLandingGetShowcaseProductFooterView {

            .init(
                landingId: model.landingId,
                event: event,
                config: config,
                theme: model.theme.map()
            )
    }
}
