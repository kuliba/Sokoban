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
        
        return data.data
    }
}

private extension ResponseMapper._DTO {
    
    var data: GetBannerCatalogListResponse {
        
        return .init(
            serial: serial,
            bannerCatalogList: bannerCatalogList.map {
                $0.data
            })
    }
}

private extension ResponseMapper._DTO._Item {
    
    var data: GetBannerCatalogListResponse.Item {
        
        return .init(
            productName: productName,
            conditions: conditions,
            imageLink: imageLink,
            orderLink: orderLink ?? "",
            conditionLink: conditionLink ?? "",
            action: action?.data)
    }
}

private extension ResponseMapper._DTO._Item._BannerAction {
    
    var data: GetBannerCatalogListResponse.BannerAction? {
        
        switch type {
            
        case .openDeposit:
            guard let depositProductId, let intValue = Int(depositProductId) else {
                return nil
            }
            return .init(type:.openDeposit(intValue))
        case .depositsList:
            return .init(type: .depositsList)
        case .migTransfer:
            guard let countryId else { return nil }
            return .init(type: .migTransfer(countryId))
        case .migAuthTransfer:
            guard let countryId else { return nil }
            return .init(type: .migAuthTransfer(countryId))
        case .contact:
            guard let countryId else { return nil }
            return .init(type: .contact(countryId))
        case .depositTransfer:
            guard let countryId else { return nil }
            return .init(type: .depositTransfer(countryId))
        case .landing:
            guard let target else { return nil }
            return .init(type: .landing(target))
        case .none:
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
                
                let type: _BannerActionType?
                let target: String?
                let countryId: String?
                let depositProductId: String?
                
                enum CodingKeys: String, CodingKey {
                    case type, target, countryId
                    case depositProductId = "depositProductID"
                }
            }
            
            enum _BannerActionType: String, Decodable {
                
                case openDeposit = "DEPOSIT_OPEN"
                case depositsList = "DEPOSITS"
                case migTransfer = "MIG_TRANSFER"
                case migAuthTransfer = "MIG_AUTH_TRANSFER"
                case contact = "CONTACT_TRANSFER"
                case depositTransfer = "DEPOSIT_TRANSFER"
                case landing = "LANDING"
            }
        }
    }
}
