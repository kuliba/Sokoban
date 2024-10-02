//
//  MarketShowcaseContentEffectHandlerMicroServices.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public struct MarketShowcaseContentEffectHandlerMicroServices<Landing, Failure: Error> {
    
    public let loadLanding: LoadLanding
    public init(
        loadLanding: @escaping LoadLanding
    ) {
        self.loadLanding = loadLanding
    }
}

public extension MarketShowcaseContentEffectHandlerMicroServices {
    
    typealias LoadLandingCompletion = (Result<Landing, Failure>) -> Void
    typealias LoadLanding = (String, @escaping LoadLandingCompletion) -> Void
}
extension MarketShowcaseContentEffectHandlerMicroServices {}
