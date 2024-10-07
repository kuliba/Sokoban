//
//  MarketShowcaseContentEffectHandlerMicroServices.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public struct MarketShowcaseContentEffectHandlerMicroServices<Landing, InformerPayload> {
    
    public let loadLanding: LoadLanding
    public init(
        loadLanding: @escaping LoadLanding
    ) {
        self.loadLanding = loadLanding
    }
}

public extension MarketShowcaseContentEffectHandlerMicroServices {
    
    typealias LoadLandingCompletion = (Result<Landing, BackendFailure<InformerPayload>>) -> Void
    typealias LoadLanding = (String, @escaping LoadLandingCompletion) -> Void
}
extension MarketShowcaseContentEffectHandlerMicroServices {}
