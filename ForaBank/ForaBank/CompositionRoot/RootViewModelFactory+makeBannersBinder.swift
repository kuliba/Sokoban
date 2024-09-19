//
//  RootViewModelFactory+makeBannersBinder.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import Foundation
import ForaTools
import CombineSchedulers
import Banners

extension RootViewModelFactory {
    
    static func makeBannersBinder(
        model: Model,
        httpClient: HTTPClient,
        infoNetworkLog: @escaping (String, StaticString, UInt) -> Void,
        mainScheduler: AnySchedulerOfDispatchQueue = .main,
        backgroundScheduler: AnySchedulerOfDispatchQueue = .global(qos: .userInitiated)
    ) -> LoadBanners {
        
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
                
        return loadBannersList
    }
    
    static func makeBannersForMainView(
        bannerPickerPlaceholderCount: Int,
        nanoServices: BannersNanoServices,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) -> BannersBinder {
        
        // MARK: - BannerPicker
        
        let standardNanoServicesComposer = StandardSelectedBannerDestinationNanoServicesComposer()
        let bannerPickerComposer = BannerPickerSectionBinderComposer(
            load: nanoServices.loadBanners,
            microServices: .init(
                showAll: { $1(BannerListModelStub(banners: $0)) },
                showBanner: selectBanner(composer: standardNanoServicesComposer)
            ),
            placeholderCount: bannerPickerPlaceholderCount,
            scheduler: mainScheduler
        )
        let bannerPicker = bannerPickerComposer.compose(
            prefix: [],
            suffix: (0..<6).map { _ in .placeholder(.init()) }
        )
        
        // MARK: - Banners
        
        let content = BannersContent(
            bannerPicker: bannerPicker,
            reload: {
                bannerPicker.content.event(.load)
            }
        )
        
        let reducer = BannersFlowReducer()
        let effectHandler = BannersFlowEffectHandler(
            microServices: .init()
        )
        let flow = BannersFlow(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: mainScheduler
        )
        
        return .init(content: content, flow: flow, bind: { _,_ in [] })
    }
}

extension BannersBinder {
    
    static let preview: BannersBinder = RootViewModelFactory.makeBannersForMainView(
        bannerPickerPlaceholderCount: 1,
        nanoServices: .init(
            loadBanners: {_ in },
            loadLandingByType: {_, _ in }
        ),
        mainScheduler: .main,
        backgroundScheduler: .global())
}
