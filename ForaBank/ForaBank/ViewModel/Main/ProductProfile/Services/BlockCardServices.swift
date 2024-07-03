//
//  BlockCardServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import ProductProfile
import RemoteServices

struct BlockCardServices {
    
    typealias CreateBlockCard = (Payloads.CardPayload, @escaping GetBlockCardCompletion) -> Void
    typealias BlockCardResult = Result<BlockUnblockData?, MappingError>
    typealias GetBlockCardCompletion = (BlockCardResult) -> Void
    typealias GetBlockCardData = (URL, @escaping GetBlockCardCompletion) -> Void
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>

    let createBlockCard: CreateBlockCard
}

// MARK: - Preview Content

extension BlockCardServices {
    
    static func preview() -> Self {
        
        .init(createBlockCard: { _, completion in
            
            completion(.success(.init(statusBrief: "", statusDescription: "")))
        })
    }
    
    static func preview(
        createBlockCardStub: BlockCardResult
    ) -> Self {
        
        .init(
            createBlockCard: { _, completion in
                
                completion(createBlockCardStub)
            }
        )
    }
}
