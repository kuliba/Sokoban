//
//  CollateralLoanLandingShowCaseViewFactory+HeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

extension CollateralLoanLandingShowCaseViewFactory {
    
    func makeHeaderView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductHeaderView {

            .init(
                title: model.name,
                config: config,
                theme: CollateralLoanLandingShowCaseTheme.map(model.theme)
            )
    }
}
