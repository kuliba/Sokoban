//
//  RootViewModelFactory+makeBannersBox.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import Foundation
import RemoteServices
import GetBannersMyProductListService

extension RootViewModelFactory {
    
    @inlinable
    func makeBannersBox(
        flags: FeatureFlags
    ) -> BannersBox<BannerList> {

        let bannersRemoteLoad = nanoServiceComposer.composeSerialResultLoad(
            createRequest: { try RequestFactory.createGetBannersMyProductListV2Request($0) },
            mapResponse: { data, response in
                
                let response = RemoteServices.ResponseMapper.mapGetBannersMyProductListResponse(data, response)
                
                return response.map {
                    
                    let value: [GetBannersMyProductListResponseCodable] = [$0.codable]
                    return .init(value: value , serial: $0.serial)
                }
            }
        )
        
        let (_, reload) = composeLoaders(
            remoteLoad: bannersRemoteLoad,
            fromModel: { $0 },
            toModel: { $0 }
        )
        
        return .init(load: { completion in
            
            reload {
                
                completion(($0 ?? []).first.map {
                    .init(
                        cardBannerList: $0.cardBannerList?.map(\.bannerItem),
                        accountBannerList: $0.accountBannerList?.map(\.bannerItem),
                        loanBannerList: $0.loanBannerList?.map(\.bannerItem))
                })
            }
        })
    }
}

private extension RemoteServices.ResponseMapper.GetBannersMyProductListResponse {

    var bannerList: BannerList {
        
        .init(
            cardBannerList: cardBannerList?.compactMap(\.item),
            accountBannerList: accountBannerList?.compactMap(\.item),
            loanBannerList: loanBannerList?.compactMap(\.item)
        )
    }
    
    var codable: GetBannersMyProductListResponseCodable {
        
        .init(
            accountBannerList: accountBannerList?.compactMap(\.itemCodable),
            cardBannerList: cardBannerList?.compactMap(\.itemCodable),
            loanBannerList: loanBannerList?.compactMap(\.itemCodable)
        )
    }
}

private extension RemoteServices.ResponseMapper.GetBannersMyProductListResponse.Banner {
    
    var item: BannerList.Item? {
        .init(action: action?.action, link: link, md5hash: md5hash, productName: productName)
    }
}

private extension RemoteServices.ResponseMapper.GetBannersMyProductListResponse.Banner.Action {
    
    var action: BannerList.Action {
       return .init(actionType: actionType, target: target)
    }
}

private extension RemoteServices.ResponseMapper.GetBannersMyProductListResponse.Banner {
    
    var itemCodable: GetBannersMyProductListResponseCodable.Item? {
        .init(action: action?.actionCodable, link: link, md5hash: md5hash, productName: productName)
    }
}

private extension RemoteServices.ResponseMapper.GetBannersMyProductListResponse.Banner.Action {
    
    var actionCodable: GetBannersMyProductListResponseCodable.Action {
       return .init(actionType: actionType, target: target)
    }
}

private extension GetBannersMyProductListResponseCodable.Item {
    
    var bannerItem: BannerList.Item {
        .init(action: action?.bannerAction, link: link, md5hash: md5hash, productName: productName)
    }
}

private extension GetBannersMyProductListResponseCodable.Action {
    
    var bannerAction: BannerList.Action {
       return .init(actionType: actionType, target: target)
    }
}
