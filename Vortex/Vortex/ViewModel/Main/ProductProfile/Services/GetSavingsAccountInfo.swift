//
//  GetSavingsAccountInfoServices.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation
import RemoteServices
import SavingsServices

struct GetSavingsAccountInfoServices {
    
    typealias CreateGetSAInfo = (GetSavingsAccountInfoPayload, @escaping GetSAInfoCompletion) -> Void
    typealias GetSAInfoResult = Result<GetSavingsAccountInfoResponse, MappingError>
    typealias GetSAInfoCompletion = (GetSAInfoResult) -> Void
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>

    typealias SAInfo = GetSavingsAccountInfoResponse
    
    let createGetSavingsAccountInfo: CreateGetSAInfo
}

// MARK: - Preview Content

extension GetSavingsAccountInfoServices {
    
    static func preview() -> Self {
        
        .init(createGetSavingsAccountInfo: { _, completion in
            
            completion(.success(.init(dateNext: "", interestAmount: 4, interestPaid: 5, minRest: 6)))
        })
    }
    
    static func preview(
        createGetSAInfoStub: GetSAInfoResult
    ) -> Self {
        
        .init(
            createGetSavingsAccountInfo: { _, completion in
                
                completion(createGetSAInfoStub)
            }
        )
    }
}
