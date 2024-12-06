//
//  MarketShowcaseComposerNanoServices.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.09.2024.
//

import Foundation
import LandingMapping

struct MarketShowcaseComposerNanoServices {
    
    let loadLanding: LoadLanding
    let orderCard: OrderCard
    let orderSticker: OrderSticker
    
    typealias LandingType = String
    typealias LoadLandingCompletion = (Result<MarketShowcaseDomain.Landing, MarketShowcaseDomain.ContentError>) -> Void
    typealias LoadLanding = (LandingType, @escaping LoadLandingCompletion) -> Void
    
    typealias OrderCardCompletion = (MarketShowcaseDomain.Destination) -> Void
    typealias OrderCard = (@escaping OrderCardCompletion) -> Void
    
    typealias OrderStickerCompletion = (MarketShowcaseDomain.Destination) -> Void
    typealias OrderSticker = (@escaping OrderStickerCompletion) -> Void
}
