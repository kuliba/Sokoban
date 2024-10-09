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
        .init(
            serial: self.data?.serial,
            products: self.data?.products?.map(\.self.map) ?? []
        )
    }
}

private extension ResponseMapper.CollateralLoanLandingShowCaseCodable.Product {
    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product {
        .init(
            theme: self.theme?.map ?? .unknown,
            name: self.name,
            terms: self.terms,
            landingId: self.landingId,
            keyMarketingParams: self.keyMarketingParams?.map,
            features: self.features?.map
        )
    }
}

private extension ResponseMapper.CollateralLoanLandingShowCaseCodable.Product.Theme {
    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Theme {
        switch self {
        case .gray: return .gray
        case .white: return .white
        case .unknown: return .unknown
        }
    }
}

private extension ResponseMapper.CollateralLoanLandingShowCaseCodable.Product.Features {
    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features {
        .init(
            header: self.header,
            image: self.image,
            lists: self.lists?.map(\.self.map) ?? []
        )
    }
}

private extension ResponseMapper.CollateralLoanLandingShowCaseCodable.Product.Features.List {
    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product.Features.List {
        .init(
            bullet: self.bullet,
            text: self.text
        )
    }
}

private extension ResponseMapper.CollateralLoanLandingShowCaseCodable.Product.KeyMarketingParams {
    var map: ResponseMapper.CollateralLoanLandingShowCaseModel.Product.KeyMarketingParams {
        .init(
            rate: self.rate,
            amount: self.amount,
            term: self.term
        )
    }
}

private extension ResponseMapper {
    struct _Data: Codable {
        let statusCode: Int?
        let errorMessage: String?
        let data: CollateralLoanLandingShowCaseCodable?
    }
    
    struct CollateralLoanLandingShowCaseCodable: Codable {
        let serial: String?
        let products: [Product]?
        
        struct Product: Codable {
            let theme: Theme?
            let name: String?
            let terms: String?
            let landingId: String?
            let keyMarketingParams: KeyMarketingParams?
            let features: Features?
            
            enum Theme: String, Codable {
                case gray = "GRAY"
                case white = "WHITE"
                case unknown
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    let stringValue = try container.decode(String.self)
                    self = .init(rawValue: stringValue) ?? .unknown
                }
            }
            
            struct KeyMarketingParams: Codable {
                let rate: String?
                let amount: String?
                let term: String?
            }
            
            struct Features: Codable {
                let header: String?
                let image: String?
                let lists: [List]?
                
                struct List: Codable {
                    let bullet: String?
                    let text: String?
                }
            }
        }
    }
}
