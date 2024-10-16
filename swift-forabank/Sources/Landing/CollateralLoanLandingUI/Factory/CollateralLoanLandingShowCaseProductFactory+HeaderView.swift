//
//  CollateralLoanLandingShowCaseProductFactory+HeaderView.swift
//
//
//  Created by Valentin Ozerov on 14.10.2024.
//

extension CollateralLoanLandingShowCaseProductFactory {
    
    func makeHeaderView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductHeaderView? {

            guard
                let name = model.name
            else {
                return nil
            }
            
            return .init(
                title: name,
                config: config,
                theme: CollateralLoanLandingShowCaseTheme.map(model.theme)
            )
    }
}
