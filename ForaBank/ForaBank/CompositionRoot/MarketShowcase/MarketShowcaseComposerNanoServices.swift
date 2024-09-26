//
//  MarketShowcaseComposerNanoServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.09.2024.
//

import Foundation

struct MarketShowcaseComposerNanoServices {
    
    let loadLanding: LoadLanding
    let orderCard: OrderCard
    let orderSticker: OrderSticker
    
    typealias LoadLandingCompletion = (Result<MarketShowcaseDomain.Landing, Error>) -> Void
    typealias LoadLanding = (@escaping LoadLandingCompletion) -> Void
    
    typealias OrderCardCompletion = (MarketShowcaseDomain.Destination) -> Void
    typealias OrderCard = (@escaping OrderCardCompletion) -> Void
    
    typealias OrderStickerCompletion = (MarketShowcaseDomain.Destination) -> Void
    typealias OrderSticker = (@escaping OrderStickerCompletion) -> Void
}
