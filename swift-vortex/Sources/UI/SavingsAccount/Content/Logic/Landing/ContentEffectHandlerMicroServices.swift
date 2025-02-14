//
//  ContentEffectHandlerMicroServices.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

public struct ContentEffectHandlerMicroServices<Landing, InformerPayload> {
    
    public let loadLanding: LoadLanding
    
    public init(
        loadLanding: @escaping LoadLanding
    ) {
        self.loadLanding = loadLanding
    }
}

public extension ContentEffectHandlerMicroServices {
    
    typealias LoadLandingCompletion = (Result<Landing, BackendFailure<InformerPayload>>) -> Void
    typealias LoadLanding = (String, @escaping LoadLandingCompletion) -> Void
}
