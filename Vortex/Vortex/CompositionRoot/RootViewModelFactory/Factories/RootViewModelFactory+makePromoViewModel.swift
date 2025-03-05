//
//  RootViewModelFactory+makePromoViewModel.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.01.2025.
//

import Foundation

extension RootViewModelFactory {

    func makePromoViewModel(
        viewModel: PromoItem,
        featureFlags: FeatureFlags,
        actions: PromoProductActions
    ) -> AdditionalProductViewModel? {
       
        let needShow = {
            switch viewModel.promoProduct {
            case .sticker:        return true
            case .savingsAccount: return true
            case .collateralLoan: return featureFlags.collateralLoanLandingFlag.isActive
            }
        }()
        
        if needShow {
            return viewModel.mapper(
                onTap: actions.show,
                onHide: actions.hide
            )
        }
        
        return nil
    }
}
