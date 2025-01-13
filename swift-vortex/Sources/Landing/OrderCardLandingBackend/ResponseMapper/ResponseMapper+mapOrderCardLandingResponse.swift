//
//  ResponseMapper+mapOrderCardResponse.swift
//
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import Foundation
import RemoteServices

public typealias ResponseMapper = RemoteServices.ResponseMapper

public extension ResponseMapper {
    
    static func mapOrderCardLandingResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<OrderCardLandingResponse> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> OrderCardLandingResponse {

        try data.getOrderCardLanding()
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getOrderCardLanding() throws
    -> OrderCardLandingResponse {

        return .init(
            id: id,
            theme: theme,
            product: .init(
                title: product.title,
                image: product.image,
                features: product.features,
                discount: .init(
                    title: product.discount.title,
                    list: product.discount.list.map({ .init(
                        title: $0.title,
                        subtitle: $0.subtitle,
                        md5hash: $0.md5hash
                    )})
                )
            ),
            conditions: .init(
                title: conditions.title,
                list: conditions.list.map({ .init(
                    title: $0.title,
                    subtitle: $0.subtitle,
                    md5hash: $0.md5hash
                )})
            ),
            security: .init(
                title: security.title,
                list: security.list.map({ .init(
                    title: $0.title,
                    subtitle: $0.subtitle,
                    md5hash: $0.md5hash
                )})
            ),
            frequentlyAskedQuestions: .init(
                title: frequentlyAskedQuestions.title,
                list: frequentlyAskedQuestions.list.map({ .init(
                    title: $0.title,
                    subtitle: $0.subtitle,
                    md5hash: $0.md5hash
                )})
            )
        )
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let id: String
        let theme: String
        let product: Product
        let conditions: Condition
        let security: Security
        let frequentlyAskedQuestions: Question
        
        struct Question: Decodable {
            
            let title: String
            let list: [Item]
        }
        
        struct Security: Decodable {
            
            let title: String
            let list: [Item]
        }
        
        struct Condition: Decodable {
            
            let title: String
            let list: [Item]
        }
        
        struct Product: Decodable {
            
            let title: String
            let image: String
            let features: [String]
            let discount: Discount
            
            struct Discount: Decodable {
                
                let title: String
                let list: [Item]
            }
        }
        
        struct Item: Decodable {
            
            let title: String
            let subtitle: String?
            let md5hash: String
        }
    }
}
