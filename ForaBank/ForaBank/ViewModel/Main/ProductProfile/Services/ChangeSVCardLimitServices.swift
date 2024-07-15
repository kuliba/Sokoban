//
//  ChangeSVCardLimitServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.07.2024.
//

import Foundation
import SVCardLimitAPI
import RemoteServices

struct ChangeSVCardLimitServices {
    
    typealias CreateChangeSVCardLimit = (ChangeSVCardLimitPayload, @escaping ChangeSVCardLimitCompletion) -> Void
    typealias ChangeSVCardLimitResult = Result<Void, MappingError>
    typealias ChangeSVCardLimitCompletion = (ChangeSVCardLimitResult) -> Void
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>

    let createChangeSVCardLimit: CreateChangeSVCardLimit
}

// MARK: - Preview Content

extension ChangeSVCardLimitServices {
    
    static func preview() -> Self {
        
        .init(createChangeSVCardLimit: { _, completion in
            
            completion(.success(()))
        })
    }
    
    static func preview(
        createChangeSVCardLimitStub: ChangeSVCardLimitResult
    ) -> Self {
        
        .init(
            createChangeSVCardLimit: { _, completion in
                
                completion(createChangeSVCardLimitStub)
            }
        )
    }
}

