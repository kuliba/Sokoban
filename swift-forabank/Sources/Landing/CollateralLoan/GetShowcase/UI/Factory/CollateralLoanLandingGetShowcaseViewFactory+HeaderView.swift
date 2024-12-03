//
//  CollateralLoanLandingGetShowcaseViewFactory+HeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    func makeHeaderView(with model: CollateralLoanLandingGetShowcaseData.Product)
        -> CollateralLoanLandingGetShowcaseProductHeaderView {

            .init(
                title: model.name,
                config: config,
                theme: model.theme.map()
            )
    }
}
