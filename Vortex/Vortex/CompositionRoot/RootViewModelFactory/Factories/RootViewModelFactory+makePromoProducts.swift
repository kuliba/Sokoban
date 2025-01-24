//
//  RootViewModelFactory+makePromoProducts.swift
//  Vortex
//
//  Created by Andryusina Nataly on 23.01.2025.
//

import Foundation

extension RootViewModelFactory {
    
    func makePromoProducts(
    ) -> [PromoItem]? {
        
        guard let sticker = model.productListBannersWithSticker.value.first
        else { return nil }

        return [
            .init(sticker)
        ]
    }
    
    func makePromoViewModel(
        viewModel: StickerBannersMyProductList,
        actions: PromoProductActions
    ) -> AdditionalProductViewModel? {
                
        return viewModel.mapper(
            md5Hash: viewModel.md5hash,
            onTap: actions.show,
            onHide: actions.hide
        )
    }
}
