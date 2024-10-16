//
//  CollateralLoanLandingShowCaseProductFactory+ImageView.swift
//
//
//  Created by Valentin Ozerov on 15.10.2024.
//

extension CollateralLoanLandingShowCaseProductFactory {
    
    func makeImageView(with model: CollateralLoanLandingShowCaseUIModel.Product)
        -> CollateralLoanLandingShowCaseProductImageView? {

            guard
                let url = model.image
            else {
                return nil
            }
            
            return .init(
                url: url,
                config: config
            )
    }
}
