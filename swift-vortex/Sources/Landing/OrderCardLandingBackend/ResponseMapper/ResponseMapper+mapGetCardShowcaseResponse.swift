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
    
    struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getCardShowcase() throws
    -> CardShowCaseResponse {
        
        guard let products else {
            throw ResponseMapper.InvalidResponse()
        }
        
        let mapProducts = try products.compactMap({
            
            guard let theme = $0.theme,
                  let image = $0.image,
                  let terms = $0.terms,
                  let name = $0.name,
                  let features = $0.features,
                  let list = features.list,
                  let cardShowcaseAction = $0.cardShowcaseAction,
                  let type = cardShowcaseAction.type,
                  let target = cardShowcaseAction.target
            else {
                throw ResponseMapper.InvalidResponse()
            }
            
            return CardShowCaseResponse.Product(
                theme: theme,
                name: name.compactMap { try? .init(data: $0) },
                features: .init(
                    header: features.header,
                    list: list.compactMap { try? .init(data: $0) }
                ),
                image: image,
                terms: terms,
                cardShowcaseAction: .init(
                    type: type,
                    target: target,
                    fallbackUrl: cardShowcaseAction.fallbackUrl
                )
            )
        })
        
        return .init(products: mapProducts)
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let products: [Product]?
        
        struct Product: Decodable {
            
            let theme: String?
            let name: [Name]?
            let features: Features?
            let image: String?
            let terms: String?
            let cardShowcaseAction: Action?
            
            struct Action: Decodable {
                
                let type: String?
                let target: String?
                let fallbackUrl: String?
            }
            
            struct Features: Decodable {
                
                let header: String?
                let list: [Item]?
                
                struct Item: Decodable {
                    
                    let bullet: Bool?
                    let text: String?
                }
            }
            
            struct Name: Decodable {
                
                let text: String?
                let isBold: Bool?
            }
        }
    }
}

private extension CardShowCaseResponse.Product.Features.Item {
    
    init?(data: ResponseMapper._Data.Product.Features.Item?) throws {
        
        guard let text = data?.text,
              let bullet = data?.bullet else {
            throw ResponseMapper.InvalidResponse()
        }
        
        self.bullet = bullet
        self.text = text
    }
}

private extension CardShowCaseResponse.Product.Name {
    
    init?(data: ResponseMapper._Data.Product.Name?) throws {
        
        guard let text = data?.text,
              let isBold = data?.isBold else {
            throw ResponseMapper.InvalidResponse()
        }
        
        self.isBold = isBold
        self.text = text
    }
}
