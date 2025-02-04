//
//  Response+mapGetBannerCatalogListResponse.swift
//
//
//  Created by Andryusina Nataly on 29.08.2024.
//

import Foundation
import RemoteServices

public typealias ResponseMapper = RemoteServices.ResponseMapper
public typealias MappingError = RemoteServices.ResponseMapper.MappingError

public extension ResponseMapper {
    
    typealias GetBannerCatalogListResult = Result<GetBannerCatalogListResponse, MappingError>
    
    static func mapGetBannerCatalogListResponse(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> GetBannerCatalogListResult {
        
        map(data, response, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _DTO
    ) throws -> GetBannerCatalogListResponse {
        
        guard let serial = data.serial
        else { throw ResponseFailure() }
        
        return .init(
            serial: serial,
            bannerCatalogList: data.bannerCatalogList.map {
                $0.data
            })
    }
    
    struct ResponseFailure: Error {}
}

private extension ResponseMapper._DTO._Item {
    
    var data: GetBannerCatalogListResponse.Item {
        
        return .init(
            productName: productName,
            conditions: conditions,
            links: .init(
                image: imageLink,
                order: orderLink ?? "",
                condition: conditionLink ?? ""),
            action: action?.data)
    }
}

private extension ResponseMapper._DTO._Item._BannerAction {
        
    var data: GetBannerCatalogListResponse.BannerAction? {
        
        switch type {
        case "DEPOSIT_OPEN":
            guard let depositProductId else { return nil }
            return .init(type:.openDeposit(depositProductId))
            
        case "DEPOSITS":
            return .init(type: .depositsList)
            
        case "MIG_TRANSFER":
            guard let countryId else { return nil }
            return .init(type: .migTransfer(countryId))
            
        case "MIG_AUTH_TRANSFER":
            guard let countryId else { return nil }
            return .init(type: .migAuthTransfer(countryId))
            
        case "CONTACT_TRANSFER":
            guard let countryId else { return nil }
            return .init(type: .contact(countryId))
            
        case "DEPOSIT_TRANSFER":
            guard let countryId else { return nil }
            return .init(type: .depositTransfer(countryId))
            
        case "LANDING":
            guard let target else { return nil }
            return .init(type: .landing(target))
            
        case "SAVING_LANDING":
            guard let target else { return nil }
            return .init(type: .savingLanding(target))

        case "HOUSING_AND_COMMUNAL_SERVICE":
            return .init(type: .payment("HOUSING_AND_COMMUNAL_SERVICE"))
            
        case "CARD_ORDER":
            return .init(type: .cardOrder)
            
        case .none, .some:
            return nil
        }
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let serial: String?
        let bannerCatalogList: [_Item]
        
        enum CodingKeys: String, CodingKey {
            
            case bannerCatalogList = "BannerCatalogList"
            case serial
        }
        
        struct _Item: Decodable {
            
            let productName: String
            let conditions: [String]
            let imageLink: String
            let orderLink: String?
            let conditionLink: String?
            let action: _BannerAction?
            
            enum CodingKeys: String, CodingKey {
                
                case productName, action
                case conditions = "txtСondition"
                case imageLink
                case orderLink
                case conditionLink
            }
            
            struct _BannerAction: Decodable {
                
                let type: String?
                let target: String?
                let countryId: String?
                let depositProductId: String?
                
                enum CodingKeys: String, CodingKey {
                    case type, target, countryId
                    case depositProductId = "depositProductID"
                }
            }
        }
    }
}
