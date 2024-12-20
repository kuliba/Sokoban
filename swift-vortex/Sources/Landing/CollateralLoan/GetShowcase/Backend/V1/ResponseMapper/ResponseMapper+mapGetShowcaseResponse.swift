//
//  ResponseMapper+mapGetShowcaseResponse.swift
//  swift-vortex
//
//  Created by Valentin Ozerov on 07.10.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCreateGetShowcaseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetShowcaseData> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> GetShowcaseData {

        try data.getGetShowcaseData()
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getGetShowcaseData() throws -> ResponseMapper.GetShowcaseData {
        
        guard
            let serial,
            let products
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            serial: serial,
            products: try products.map { try $0.map() }
        )
    }
}

private extension ResponseMapper._Data.Product {

    func map() throws -> ResponseMapper.GetShowcaseData.Product {
        
        guard
            let name,
            let terms,
            let landingId,
            let image,
            let keyMarketingParams,
            let features
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            theme: themeMap,
            name: name,
            terms: terms,
            landingId: landingId,
            image: image,
            keyMarketingParams: try keyMarketingParams.map(),
            features: try features.map()
        )
    }
}

private extension ResponseMapper._Data.Product {

    typealias Theme = ResponseMapper.GetShowcaseData.Product.Theme
    
    var themeMap: Theme {
        
        var theme = Theme.unknown
        
        if let themeFromData = self.theme,
           let themeMap = Theme(rawValue: themeFromData.lowercased()) {
            theme = themeMap
        }

        return theme
    }
}

private extension ResponseMapper._Data.Product.Features {

    func map() throws -> ResponseMapper.GetShowcaseData.Product.Features {
        
        guard
            let list
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            header: header,
            list: try list.map { try $0.map() }
        )
    }
}

private extension ResponseMapper._Data.Product.Features.List {

    func map() throws -> ResponseMapper.GetShowcaseData.Product.Features.List {
        
        guard
            let bullet,
            let text
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            bullet: bullet,
            text: text
        )
    }
}

private extension ResponseMapper._Data.Product.KeyMarketingParams {

    func map() throws -> ResponseMapper.GetShowcaseData.Product.KeyMarketingParams {
        
        guard
            let rate,
            let amount,
            let term
        else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            rate: rate,
            amount: amount,
            term: term
        )
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let serial: String?
        let products: [Product]?
        
        struct Product: Decodable {

            let theme: String?
            let name: String?
            let terms: String?
            let landingId: String?
            let image: String?
            let keyMarketingParams: KeyMarketingParams?
            let features: Features?
                        
            struct KeyMarketingParams: Decodable {

                let rate: String?
                let amount: String?
                let term: String?
            }
            
            struct Features: Decodable {

                let header: String?
                let list: [List]?
                
                struct List: Decodable {

                    let bullet: Bool?
                    let text: String?
                }
            }
        }
    }
}
