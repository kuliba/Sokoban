//
//  ResponseMapper+mapCreateGetBannersMyProductListApplicationResponse.swift
//
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCreateGetBannersMyProductListApplicationResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateGetBannersMyProductListApplicationDomain> {

        map(
            data, httpURLResponse,
            mapOrThrow: map
        )
    }
    
    private static func map(_ data: _Data) -> CreateGetBannersMyProductListApplicationDomain {

        data.getCreateGetBannersMyProductListApplicationResponse()
    }
    
    typealias Response = ResponseMapper.CreateGetBannersMyProductListApplicationDomain

}

private extension ResponseMapper._Data {
    
    func getCreateGetBannersMyProductListApplicationResponse() -> ResponseMapper.Response {
        
        .init(
            loanBannerList: loanBannerList?.map { $0.map() } ?? [],
            cardBannerList: cardBannerList?.map { $0.map() } ?? []
        )
    }
}

private extension ResponseMapper._Data.Banner {
    
    func map() -> ResponseMapper.Response.Banner {
        
        .init(
            productName: productName,
            link: link,
            md5hash: md5hash,
            action: action?.map()
        )
    }
}

private extension ResponseMapper._Data.Banner.Action {
    
    func map() -> ResponseMapper.Response.Banner.Action {
        
        .init(actionType: mapType(), landingDate: landingDate, target: target)
    }
    
    func mapType()
    -> ResponseMapper.Response.Banner.Action.ActionType {
        
        ResponseMapper.Response.Banner.Action.ActionType(rawValue: actionType.uppercased()) ?? .unknown
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let serial: String
        let loanBannerList: [Banner]?
        let cardBannerList: [Banner]?

        struct Banner: Decodable {
            let productName: String
            let link: String
            let md5hash: String
            let action: Action?
            
            struct Action: Decodable {
                let actionType: String
                let landingDate: String?
                let target: String?
            }
        }
    }
}
