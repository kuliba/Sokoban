//
//  MarketShowcaseComposerNanoServicesComposer.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.09.2024.
//

import Foundation

final class MarketShowcaseComposerNanoServicesComposer {}

extension MarketShowcaseComposerNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            loadLanding: loadLanding,
            orderCard: orderCard,
            orderSticker: orderSticker)
    }
    
    typealias NanoServices = MarketShowcaseComposerNanoServices
}

extension MarketShowcaseComposerNanoServicesComposer {
    
    // TODO: fix, add tests
    func loadLanding(
        completion: @escaping (Result<MarketShowcaseDomain.Landing, Error>) -> Void
    ) {
        
    }
    
    // TODO: fix, add tests
    func orderCard(
        completion: @escaping (()) -> Void
    ) {
        
    }
    
    // TODO: fix, add tests
    func orderSticker(
        completion: @escaping (()) -> Void
    ) {
        
    }
}
