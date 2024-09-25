//
//  RootViewModelFactory+makePaymentsTransfersCorporate.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import Banners
import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    typealias LoadLatestOperationsCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadLatestOperations = (@escaping LoadLatestOperationsCompletion) -> Void
    
    typealias LoadServiceCategoriesCompletion = ([CategoryPickerSectionItem<ServiceCategory>]) -> Void
    typealias LoadServiceCategories = (@escaping LoadServiceCategoriesCompletion) -> Void
    
    static func makePaymentsTransfersCorporate(
        bannerPickerPlaceholderCount: Int,
        nanoServices: PaymentsTransfersCorporateNanoServices,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) -> PaymentsTransfersCorporate {
        
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
        
        // MARK: - PaymentsTransfers
        
        let content = PaymentsTransfersCorporateContent(
            bannerPicker: bannerPicker,
            reload: {
                bannerPicker.content.event(.load)
            }
        )
        
        let reducer = PayHub.PaymentsTransfersCorporateFlowReducer()
        let effectHandler = PayHub.PaymentsTransfersCorporateFlowEffectHandler(
            microServices: .init()
        )
        let flow = PaymentsTransfersCorporateFlow(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: mainScheduler
        )
        
        return .init(content: content, flow: flow, bind: { _,_ in [] })
    }
}
