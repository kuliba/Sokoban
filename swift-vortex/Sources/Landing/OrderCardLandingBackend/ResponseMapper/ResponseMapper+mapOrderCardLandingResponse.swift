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
        
        guard let theme = products.first?.theme,
              let product = products.first?.product?.product,
              let conditions = products.first?.conditions?.condition,
              let security = products.first?.security?.security,
              let frequentlyAskedQuestions = products.first?.frequentlyAskedQuestions?.question else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            theme: theme,
            product: product,
            conditions: conditions,
            security: security,
            frequentlyAskedQuestions: frequentlyAskedQuestions
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let products: [ProductItem]
        
        struct ProductItem: Decodable {
            
            let header: Header?
            let theme: String?
            let product: Product?
            let conditions: Condition?
            let security: Security?
            let frequentlyAskedQuestions: Question?
            let cardLandingAction: CardLandingAction?
        }
        
        struct CardLandingAction: Decodable {
        
            let type: String?
            let target: String?
            let fallbackUrl: String?
        }
        
        struct Header: Decodable {
            let title: String?
        }
        
        struct Question: Decodable {
            
            let title: String?
            let list: [Item]
        }
        
        struct Security: Decodable {
            
            let title: String?
            let list: [Item]
        }
        
        struct Condition: Decodable {
            
            let title: String?
            let list: [Item]
        }
        
        struct Product: Decodable {
            
            let title: String?
            let name: [Name]?
            let image: String?
            let features: [String]
            let discounts: Discount?
            
            struct Name: Decodable {
            
                let text: String?
                let isBold: Bool?
            }
            
            struct Discount: Decodable {
                
                let title: String?
                let list: [Item]
            }
        }
        
        struct Item: Decodable {
            
            let title: String?
            let subtitle: String?
            let md5hash: String?
        }
    }
}

private extension ResponseMapper._Data.Question {
    
    var question: OrderCardLandingResponse.Question? {
        
        guard let title,
              !title.isEmpty,
              !list.isEmpty else {
            return nil
        }
        
        return .init(
            title: title,
            list: list.compactMap(\.item)
        )
    }
}

private extension ResponseMapper._Data.Product {
    
    var product: OrderCardLandingResponse.Product? {
        
//        guard let title,
//              let image,
//              !features.isEmpty,
//              let discounts else {
//            return nil
//        }
    
        return .init(
            title: title ?? "",
            image: image ?? "",
            features: features,
            discount: .init(
                title: title ?? "",
                list: []
            )
        )
    }
}

private extension ResponseMapper._Data.Product.Discount {
    
    var product: OrderCardLandingResponse.Product.Discount? {
        
        guard let title,
              !list.isEmpty else {
            return nil
        }
        
        return .init(
            title: title,
            list: list.compactMap(\.item)
        )
    }
}

private extension ResponseMapper._Data.Condition {
    
    var condition: OrderCardLandingResponse.Condition? {
        
        guard let title,
              !list.isEmpty else {
            return nil
        }
        
        return .init(
            title: title,
            list: list.compactMap(\.item)
        )
    }
}

private extension ResponseMapper._Data.Security {
    
    var security: OrderCardLandingResponse.Security? {
        
        guard let title,
              !list.isEmpty else {
            return nil
        }
        
        return .init(
            title: title,
            list: list.compactMap(\.item)
        )
    }
}

private extension ResponseMapper._Data.Item {
    
    var item: OrderCardLandingResponse.Item? {
        
        guard let title,
              let md5hash else {
            return nil
        }
        
        return .init(
            title: title,
            subtitle: subtitle,
            md5hash: md5hash
        )
    }
}
