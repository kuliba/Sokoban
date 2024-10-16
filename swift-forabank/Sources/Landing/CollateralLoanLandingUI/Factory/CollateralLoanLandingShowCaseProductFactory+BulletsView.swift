//
//  CollateralLoanLandingShowCaseProductFactory+BulletsView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseProductFactory {
    
    func makeBulletsView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductBulletsView? {

            guard
                let bulletsData = model.features?.list
            else {
                return nil
            }
            
            return .init(
                header: model.features?.header,
                bulletsData: bulletsData.map { ($0.bullet, $0.text) },
                config: config,
                theme: CollateralLoanLandingShowCaseTheme.map(model.theme)
            )
    }
}
