//
//  UserVisibilityProductsSettingsServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.07.2024.
//

import Foundation
import ProductProfile
import RemoteServices

struct UserVisibilityProductsSettingsServices {
    
    typealias CreateUserVisibilityProductsSettings = (Payloads.ProductsVisibilityPayload, @escaping GetUserVisibilityProductsSettingsCompletion) -> Void
    typealias UserVisibilityProductsSettingsResult = Result<Void, MappingError>
    typealias GetUserVisibilityProductsSettingsCompletion = (UserVisibilityProductsSettingsResult) -> Void
    typealias GetUserVisibilityProductsSettingsData = (URL, @escaping GetUserVisibilityProductsSettingsCompletion) -> Void
    typealias MappingError = MappingRemoteServiceError<RemoteServices.ResponseMapper.MappingError>

    let createUserVisibilityProductsSettings: CreateUserVisibilityProductsSettings
}

// MARK: - Preview Content

extension UserVisibilityProductsSettingsServices {
    
    static func preview() -> Self {
        
        .init(createUserVisibilityProductsSettings: { _, completion in
            
            completion(.success(()))
        })
    }
}
