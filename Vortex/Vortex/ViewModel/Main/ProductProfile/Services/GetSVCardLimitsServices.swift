//
//  GetSVCardLimitsServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.07.2024.
//

import Foundation
import SVCardLimitAPI
import RemoteServices

struct GetSVCardLimitsServices {
    
    typealias CreateGetSVCardLimits = (GetSVCardLimitsPayload, @escaping GetSVCardLimitsCompletion) -> Void
    typealias GetSVCardLimitsResult = Result<GetSVCardLimitsResponse, MappingError>
    typealias GetSVCardLimitsCompletion = (GetSVCardLimitsResult) -> Void
    typealias GetSVCardLimitsData = (URL, @escaping GetSVCardLimitsCompletion) -> Void
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>

    let createGetSVCardLimits: CreateGetSVCardLimits
}

// MARK: - Preview Content

extension GetSVCardLimitsServices {
    
    static func preview() -> Self {
        
        .init(createGetSVCardLimits: { _, completion in
            
            completion(.success(.init(limitsList: [.init(type: "Debit", limits: [.init(currency: 810, currentValue: 10, name: "Limit", value: 10)])], serial: "11")))
        })
    }
    
    static func preview(
        createGetSVCardLimitsStub: GetSVCardLimitsResult
    ) -> Self {
        
        .init(
            createGetSVCardLimits: { _, completion in
                
                completion(createGetSVCardLimitsStub)
            }
        )
    }
}
