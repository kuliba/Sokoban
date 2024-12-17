//
//  SVCardLandingServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.07.2024.
//

import Foundation
import LandingMapping
import RemoteServices

struct SVCardLandingServices {
    
    typealias CreateSVCardLanding = (Services.GetLanding, @escaping GetSVCardLandingCompletion) -> Void
    typealias SVCardLandingResult = Result<Landing, MappingError>
    typealias GetSVCardLandingCompletion = (SVCardLandingResult) -> Void
    typealias MappingError = MappingRemoteServiceError<LandingMapping.LandingMapper.MapperError>

    let createSVCardLanding: CreateSVCardLanding
}

// MARK: - Preview Content

extension SVCardLandingServices {
    
    static func preview() -> Self {
        
        .init(createSVCardLanding: { _, completion in
            
            completion(.success(.init(header: [.pageTitle(.init(text: "text", subtitle: nil, transparency: false))], main: [], footer: [], details: [], serial: nil, statusCode: 0, errorMessage: nil)))
        })
    }
    
    static func preview(
        createSVCardLandingStub: SVCardLandingResult
    ) -> Self {
        
        .init(
            createSVCardLanding: { _, completion in
                
                completion(createSVCardLandingStub)
            }
        )
    }
}
