//
//  RootViewModelFactory+makeBannersBox.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import Foundation
import GetBannerCatalogListAPI

extension RootViewModelFactory {
    
    @inlinable
    func makeBannersBox(
        flags: FeatureFlags
    ) -> BannersBox<BannerList> {
        //Получение данных мини-баннеров
        // GET dict/v2/getBannersMyProductList
        /*let load = onBackground(
            makeRequest: <#T##RemoteDomainOf<Payload, Response, any Error>.MakeRequest##RemoteDomainOf<Payload, Response, any Error>.MakeRequest##(Payload) throws -> URLRequest#>,
            mapResponse: <#T##RemoteDomainOf<Payload, Response, any Error>.MapResponse##RemoteDomainOf<Payload, Response, any Error>.MapResponse##(Data, HTTPURLResponse) -> Result<Response, ResponseMapper.MappingError>#>)
        */
        
        
        return .init(load: { $0(nil) })
    }
}
