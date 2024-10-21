//
//  ResponseMapper+mapCollateralLoanShowCaseResponse.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 07.10.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCollateralLoanShowCaseResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CollateralLoanLandingShowCaseModel> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(
        _ data: _Data
    ) throws -> CollateralLoanLandingShowCaseModel {

        try data.getCollateralLoanLandingShowCaseModel()
    }
    
    private struct InvalidResponse: Error {}
}

private extension ResponseMapper._Data {
    
    func getCollateralLoanLandingShowCaseModel() throws -> ResponseMapper.CollateralLoanLandingShowCaseModel {
        
        guard let serial = self.serial else {
            throw ResponseMapper.InvalidResponse()
        }
        
        return .init(
            serial: serial,
            products: self.products?.map(\.self.map) ?? []
        )
    }
}

private extension ResponseMapper._Data.Product {

    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product {
        
        .init(
            theme: themeMap,
            name: self.name,
            terms: self.terms,
            landingId: self.landingId,
            image: self.image,
            keyMarketingParams: self.keyMarketingParams?.map,
            features: self.features?.map
        )
    }
}

private extension ResponseMapper._Data.Product {

    typealias Theme = ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Theme
    
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

    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features {
        .init(
            header: self.header,
            list: self.list?.map(\.self.map) ?? []
        )
    }
}

private extension ResponseMapper._Data.Product.Features.List {

    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features.List {
        .init(
            bullet: self.bullet,
            text: self.text
        )
    }
}

private extension ResponseMapper._Data.Product.KeyMarketingParams {

    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product.KeyMarketingParams {
        .init(
            rate: self.rate,
            amount: self.amount,
            term: self.term
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
