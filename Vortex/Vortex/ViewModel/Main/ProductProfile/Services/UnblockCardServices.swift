//
//  UnblockCardServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 07.05.2024.
//

import Foundation
import ProductProfile
import RemoteServices

struct UnblockCardServices {
    
    typealias CreateUnblockCard = (Payloads.CardPayload, @escaping GetUnblockCardCompletion) -> Void
    typealias UnblockCardResult = Result<BlockUnblockData, MappingError>
    typealias GetUnblockCardCompletion = (UnblockCardResult) -> Void
    typealias GetUnblockCardData = (URL, @escaping GetUnblockCardCompletion) -> Void
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>

    let createUnblockCard: CreateUnblockCard
}

// MARK: - Preview Content

extension UnblockCardServices {
    
    static func preview() -> Self {
        
        .init(createUnblockCard: { _, completion in
            
            completion(.success(.init(statusBrief: "", statusDescription: "")))
        })
    }
    
    static func preview(
        createUnblockCardStub: UnblockCardResult
    ) -> Self {
        
        .init(
            createUnblockCard: { _, completion in
                
                completion(createUnblockCardStub)
            }
        )
    }
}
