//
//  ResponseMapper+mapGetCardShowcaseResponse.swift
//
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetCardShowcaseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CardShowCaseResponse> {
        
        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> CardShowCaseResponse {
        
        try data.getCardShowcase()
    }
}

private extension ResponseMapper._Data {
    
    func getCardShowcase() throws
    -> CardShowCaseResponse {
        
        let products = products.map({
            CardShowCaseResponse.Product(
                theme: $0.theme,
                name: $0.name.map({ .init(text: $0.text, isBold: $0.isBold) }),
                features: .init(header: $0.features.header, list: $0.features.list.map({ .init(bullet: $0.bullet, text: $0.text) }) ),
                image: $0.image,
                terms: $0.terms,
                cardShowcaseAction: .init(
                    type: $0.cardShowcaseAction.type,
                    target: $0.cardShowcaseAction.target,
                    fallbackUrl: $0.cardShowcaseAction.fallbackUrl
                )
            )
        })
        
        return .init(products: products)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let products: [Product]
        
        struct Product: Decodable {
            
            let theme: String
            let name: [Name]
            let features: Features
            let image: String
            let terms: String
            let cardShowcaseAction: Action
            
            struct Action: Decodable {
                
                let type: String
                let target: String
                let fallbackUrl: String?
            }
            
            struct Features: Decodable {
                
                let header: String?
                let list: [Item]
                
                struct Item: Decodable {
                    
                    let bullet: Bool
                    let text: String
                }
            }
            
            struct Name: Decodable {
                
                let text: String
                let isBold: Bool
            }
        }
    }
}
