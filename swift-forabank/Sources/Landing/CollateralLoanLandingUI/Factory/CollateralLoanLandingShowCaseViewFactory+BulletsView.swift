//
//  CollateralLoanLandingShowCaseViewFactory+BulletsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseViewFactory {
    
    func makeBulletsView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductBulletsView {

            .init(
                header: model.features.header,
                bulletsData: model.features.list.map { ($0.bullet, $0.text) },
                config: config,
                theme: CollateralLoanLandingShowCaseTheme.map(model.theme)
            )
    }
}
