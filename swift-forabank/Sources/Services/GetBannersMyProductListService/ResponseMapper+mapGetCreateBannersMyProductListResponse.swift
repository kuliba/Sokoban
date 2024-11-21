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
    ) -> MappingResult<GetBannersMyProductListResponse> {

        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) -> GetBannersMyProductListResponse {

        data.mapGetBannersMyProductListResponse()
    }
    
    typealias ResponseGetBannersMyProductList = ResponseMapper.GetBannersMyProductListResponse
}

private extension ResponseMapper._Data {
    
    func mapGetBannersMyProductListResponse() -> ResponseMapper.ResponseGetBannersMyProductList {
        
        .init(
            serial: serial,
            accountBannerList: accountBannerList?.map { $0.map() } ?? [],
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
        
        .init(actionType: actionType, target: target)
    }
}

private extension ResponseMapper {

    struct _Data: Decodable {
        
        let serial: String
        let accountBannerList: [Banner]?
        let cardBannerList: [Banner]?
        let loanBannerList: [Banner]?

        struct Banner: Decodable {
            let productName: String
            let link: String
            let md5hash: String
            let action: Action?
            
            struct Action: Decodable {
                let actionType: String
                let target: String?
            }
        }
    }
}
