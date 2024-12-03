//
//  CollateralLoanLandingGetShowcaseViewFactory+BulletsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingGetShowcaseViewFactory {
    
    func makeBulletsView(with model: CollateralLoanLandingGetShowcaseData.Product)
        -> CollateralLoanLandingGetShowcaseProductBulletsView {

            .init(
                header: model.features.header,
                bulletsData: model.features.list.map { ($0.bullet, $0.text) },
                config: config,
                theme: model.theme.map()
            )
    }
}
