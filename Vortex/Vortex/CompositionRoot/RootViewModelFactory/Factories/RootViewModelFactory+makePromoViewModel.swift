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
        actions: PromoProductActions
    ) -> AdditionalProductViewModel? {
       
        let needShow = {
            switch viewModel.promoProduct {
            case .sticker:          return true
            case .savingsAccount:   return true
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
