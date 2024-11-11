//
//  ResponseMapper+mapCreateGetBannersMyProductListResponse.swift
//
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetBannersMyProductListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateGetBannersMyProductListApplicationDomain> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(_ data: _Data) -> CreateGetBannersMyProductListApplicationDomain {

        data.mapGetBannersMyProductListResponse()
    }
    
    typealias ResponseGetBannersMyProductList = ResponseMapper.CreateGetBannersMyProductListApplicationDomain
}

private extension ResponseMapper._Data {
    
    func mapGetBannersMyProductListResponse() -> ResponseMapper.ResponseGetBannersMyProductList {
        
        .init(
            cardBannerList: cardBannerList?.map { $0.map() } ?? [],
            loanBannerList: loanBannerList?.map { $0.map() } ?? []
        )
    }
}

private extension ResponseMapper._Data.Banner {
    
    func map() -> ResponseMapper.ResponseGetBannersMyProductList.Banner {
        
        .init(
            productName: productName,
            link: link,
            md5hash: md5hash,
            action: action?.map()
        )
    }
}

private extension ResponseMapper._Data.Banner.Action {
    
    func map() -> ResponseMapper.ResponseGetBannersMyProductList.Banner.Action {
        
        .init(actionType: mapType(), landingData: landingData, target: target)
    }
    
    func mapType()
    -> ResponseMapper.ResponseGetBannersMyProductList.Banner.Action.ActionType {
        
        switch actionType.uppercased() {
        case "DEPOSIT_OPEN":
            return .openDeposit
        case "DEPOSITS":
            return .depositList
        case "MIG_TRANSFER":
            return .migTransfer
        case "MIG_AUTH_TRANSFER":
            return .migAuthTransfer
        case "CONTACT_TRANSFER":
            return .contact
        case "DEPOSIT_TRANSFER":
            return .depositTransfer
        case "LANDING":
            return .landing
        default:
            return .unknown
        }
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let serial: String
        let cardBannerList: [Banner]?
        let loanBannerList: [Banner]?

        struct Banner: Decodable {
            let productName: String
            let link: String
            let md5hash: String
            let action: Action?
            
            struct Action: Decodable {
                let actionType: String
                let landingData: String?
                let target: String?
            }
        }
    }
}
