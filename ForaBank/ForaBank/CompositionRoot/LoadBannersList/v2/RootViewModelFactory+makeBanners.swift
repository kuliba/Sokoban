//
//  RootViewModelFactory+makeBanners.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.09.2024.
//

import CombineSchedulers
import Foundation
import Banners
import PayHub
import LandingMapping

struct BannersNanoServices {
    
    let loadBanners: LoadBanners
    let loadLandingByType: LoadLandingByType
}

extension BannersNanoServices {
    
    typealias LoadBannersCompletion = ([BannerPickerSectionItem<BannerCatalogListData>]) -> Void
    typealias LoadBanners = (@escaping LoadBannersCompletion) -> Void
    typealias LandingType = String
    typealias LoadLandingByTypeCompletion = (Result<Landing, Error>) -> Void
    typealias LoadLandingByType = (LandingType, @escaping LoadLandingByTypeCompletion) -> Void
}

extension RootViewModelFactory {
        
    typealias LoadServiceBannersCompletion = ([BannerPickerSectionItem<BannerCatalogListData>]) -> Void
    typealias LoadServiceBanners = (@escaping LoadServiceCategoriesCompletion) -> Void
    
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
        
        let reducer = Banners.BannersFlowReducer()
        let effectHandler = Banners.BannersFlowEffectHandler(
            microServices: .init()
        )
        let flow = Banners.BannersFlow(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: mainScheduler
        )
        
        return .init(content: content, flow: flow, bind: { _,_ in [] })
    }
    
    static func selectBanner(
        composer: StandardSelectedBannerDestinationNanoServicesComposer
    ) -> (
        BannerCatalogListData, @escaping (SelectedBannerDestination) -> Void
    ) -> Void {
        
        return { banner, completion in
            
            let standardNanoServices = composer.compose(banner: banner)
            let composer = BannerFlowMicroServiceComposerNanoServicesComposer(
                standardNanoServices: standardNanoServices
            )
            let nanoServices = composer.compose(banner: banner)
            let bannerFlowComposer = BannerFlowMicroServiceComposer(
                nanoServices: nanoServices
            )
            let microService = bannerFlowComposer.compose()
            
            microService.makeBannerFlow(.standard, completion)
        }
    }
}

final class StandardSelectedBannerDestinationNanoServicesComposer {
    
    init() {}
    
}

extension StandardSelectedBannerDestinationNanoServicesComposer {
    
    func compose(
        banner: BannerCatalogListData
    ) -> StandardNanoServices {
                
        return .init(
            makeFailure: { $0(NSError(domain: "Failure", code: -1)) },
            makeSuccess: { payload, completion in
                
                completion(.init(
                    banner: banner
                ))
            }
        )
    }
    
    typealias StandardNanoServices = StandardSelectedBannerDestinationNanoServices<BannerCatalogListData, SelectedBannerStub, Error>
}

final class BannerFlowMicroServiceComposerNanoServicesComposer {
    
    let standardNanoServices: StandardNanoServices
    
    init(
        standardNanoServices: StandardNanoServices
    ) {
        self.standardNanoServices = standardNanoServices
    }
    
    typealias StandardNanoServices = StandardSelectedBannerDestinationNanoServices<BannerCatalogListData, SelectedBannerStub, Error>
}

extension BannerFlowMicroServiceComposerNanoServicesComposer {
    
    func compose(banner: BannerCatalogListData) -> NanoServices {
        
        let standardFlowComposer = StandardSelectedBannerDestinationMicroServiceComposer(
            nanoServices: standardNanoServices
        )
        let standardMicroService = standardFlowComposer.compose()
        
        return .init(
            makeStandard: { standardMicroService.makeDestination(banner, $0) },
            makeSticker: { $0(StickerStub()) }, 
            makeLanding: { $0(LandingStub()) }
        )
    }
    
    typealias NanoServices = BannerFlowMicroServiceComposerNanoServices< Result<SelectedBannerStub, Error>, StickerStub, LandingStub>
}
