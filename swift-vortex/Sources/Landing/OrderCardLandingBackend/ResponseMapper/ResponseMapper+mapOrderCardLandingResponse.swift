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
        
        guard let id,
              let theme,
              let product = product?.product,
              let conditions = conditions?.condition,
              let security = security?.security,
              let frequentlyAskedQuestions = frequentlyAskedQuestions?.question else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            id: id,
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
        
        let id: String?
        let theme: String?
        let product: Product?
        let conditions: Condition?
        let security: Security?
        let frequentlyAskedQuestions: Question?
        
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
            let image: String?
            let features: [String]
            let discount: Discount?
            
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
        
        guard let title,
              let image,
              !features.isEmpty,
              let discount else {
            return nil
        }
    
        return .init(
            title: title,
            image: image,
            features: features,
            discount: .init(
                title: title,
                list: discount.list.compactMap(\.item)
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
