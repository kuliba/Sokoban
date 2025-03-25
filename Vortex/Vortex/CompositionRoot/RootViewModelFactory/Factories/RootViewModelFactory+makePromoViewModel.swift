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
            case .creditCardMVP:  return featureFlags.creditCardMVPFlag.isActive
            case .sticker:        return true
            case .savingsAccount: return true
            case .collateralLoan: return featureFlags.collateralLoanLandingFlag.isActive
            }
        }()
        
        if needShow {
            
            return viewModel.mapper(onTap: actions.show, onHide: actions.hide)
        }
        
        return nil
    }
}
