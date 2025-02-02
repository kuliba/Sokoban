//
//  FormContentEffectHandlerMicroServices.swift
//
//
//  Created by Andryusina Nataly on 02.02.2025.
//

import Foundation

public struct FormContentEffectHandlerMicroServices<Landing, InformerPayload> {
    
    public let loadLanding: LoadLanding
    
    public init(
        loadLanding: @escaping LoadLanding
    ) {
        self.loadLanding = loadLanding
    }
}

public extension FormContentEffectHandlerMicroServices {
    
    typealias LoadLandingCompletion = (Result<Landing, BackendFailure<InformerPayload>>) -> Void
    typealias LoadLanding = (@escaping LoadLandingCompletion) -> Void
}
