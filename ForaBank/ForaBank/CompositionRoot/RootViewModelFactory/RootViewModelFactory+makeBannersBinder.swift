//
//  RootViewModelFactory+makeBannersBinder.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import Banners
import CombineSchedulers
import ForaTools
import Foundation

extension RootViewModelFactory {
    
    func makeLoadBanners() -> LoadBanners {
        
        let localBannerListLoader = ServiceItemsLoader.default
        let getBannerList = NanoServices.makeGetBannerCatalogListV2(
            httpClient: httpClient,
            log: infoNetworkLog
        )
        
        let getBannerListLoader = AnyLoader { completion in
            
            self.schedulers.background.delay(for: .seconds(2)) {
                
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
        
        return loadBannersList
    }
}

extension BannersBinder {
    
    static let preview: BannersBinder = RootViewModelFactory(
        model: .emptyMock,
        httpClient: Model.emptyMock.authenticatedHTTPClient(),
        logger: LoggerAgent(), 
        resolveQR: { _ in .unknown },
        scanner: QRScannerView.ViewModel(),
        schedulers: .init()
    ).makeBannersForMainView(
        bannerPickerPlaceholderCount: 1,
        nanoServices: .init(
            loadBanners: {_ in },
            loadLandingByType: {_, _ in }
        )
    )
}
