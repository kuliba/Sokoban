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
        actions: PromoProductActions,
        featureFlags: FeatureFlags
    ) -> AdditionalProductViewModel? {
       
        let needShow = {
            switch viewModel.promoProduct {
            case .sticker:          return true
            case .savingsAccount:   return featureFlags.savingsAccountFlag.isActive
            case .collateralLoan, .collateralLoanCar, .collateralLoanRealEstate:
                return featureFlags.collateralLoanLandingFlag.isActive
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
