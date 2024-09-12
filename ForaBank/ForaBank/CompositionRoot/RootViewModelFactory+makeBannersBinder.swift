//
//  RootViewModelFactory+makeBannersBinder.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import Foundation
import ForaTools

extension RootViewModelFactory {
    
    static func makeBannersBinder(
        model: Model,
        httpClient: HTTPClient,
        infoNetworkLog: @escaping (String, StaticString, UInt) -> Void,
        mainScheduler: AnySchedulerOfDispatchQueue = .main,
        backgroundScheduler: AnySchedulerOfDispatchQueue = .global(qos: .userInitiated)
    ) -> (binder: BannersBinder, loader: LoadBanners) {
        
        let localBannerListLoader = ServiceItemsLoader.default
        let getBannerList = NanoServices.makeGetBannerCatalogListV2(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let getBannerListLoader = AnyLoader { completion in
            
            backgroundScheduler.delay(for: .seconds(2)) {
                
                localBannerListLoader.serial {
                    getBannerList(($0, 120)) {
                        
                        completion($0)
                    }
                }
            }
        }
        
        let bannerListDecorated = CacheDecorator(
            decoratee: getBannerListLoader,
            cache: { response, completion in
                localBannerListLoader.save(.init(response), completion)
            }
        )
        
        let loadBannersList: LoadBanners = { completion in
            
            bannerListDecorated.load {
                
                let banners = (try? $0.get()) ?? .init(bannerCatalogList: [], serial: "")
                completion(banners.bannerCatalogList.map { .banner($0)})
            }
        }
        
        let banners = makeBanners(
            model: model,
            bannerPickerPlaceholderCount: 6,
            nanoServices: .init(
                loadBanners: loadBannersList
            ),
            mainScheduler: mainScheduler,
            backgroundScheduler: backgroundScheduler
        )
        
        // call and notify bannerPicker
        loadBannersList {
            banners.content.bannerPicker.content.event(.loaded($0))
        }
        
        return (banners, loadBannersList)
    }
}
