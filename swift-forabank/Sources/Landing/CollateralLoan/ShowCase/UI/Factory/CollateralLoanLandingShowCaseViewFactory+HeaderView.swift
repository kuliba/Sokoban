//
//  CollateralLoanLandingShowCaseViewFactory+HeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

extension CollateralLoanLandingShowCaseViewFactory {
    
    func makeHeaderView(with model: CollateralLoanLandingShowCaseData.Product)
        -> CollateralLoanLandingShowCaseProductHeaderView {

            .init(
                title: model.name,
                config: config,
                theme: model.theme.map()
            )
    }
}
