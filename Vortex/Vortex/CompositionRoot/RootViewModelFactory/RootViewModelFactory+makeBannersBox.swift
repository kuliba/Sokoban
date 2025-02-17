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

        let load = onBackground(
            makeRequest: {
                
               try RequestFactory.createGetBannersMyProductListV2Request($0)
            },
            mapResponse: RemoteServices.ResponseMapper.mapGetBannersMyProductListResponse(_:_:)
        )
        
        return .init(load: { completion in
            
            load(nil) {
                completion(try? $0.map(\.bannerList).get())
            }
        })
    }
}
private extension RemoteServices.ResponseMapper.GetBannersMyProductListResponse {
   // TODO: add
    var bannerList: BannerList {
        
        .init(
            cardBannerList: [],
            depositBannerList: [],
            accountBannerList: [],
            loanBannerList: []
        )
    }
}
