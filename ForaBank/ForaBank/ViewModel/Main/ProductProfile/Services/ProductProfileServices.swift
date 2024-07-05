//
//  ProductProfileServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 29.06.2024.
//

import Foundation

struct ProductProfileServices {
    
    let createBlockCardService: BlockCardServices
    let createUnblockCardService: UnblockCardServices
    let createUserVisibilityProductsSettingsService: UserVisibilityProductsSettingsServices
}

// MARK: - Preview Content

extension ProductProfileServices {
    
    static let preview: Self = .init(
        createBlockCardService: .preview(),
        createUnblockCardService: .preview(),
        createUserVisibilityProductsSettingsService: .preview()
    )
}
