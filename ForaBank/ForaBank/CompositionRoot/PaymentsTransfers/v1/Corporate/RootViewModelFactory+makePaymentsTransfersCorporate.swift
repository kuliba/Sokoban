//
//  RootViewModelFactory+makePaymentsTransfersCorporate.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import Banners
import Combine
import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

private typealias Domain = PaymentsTransfersCorporateDomain

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentsTransfersCorporate(
        bannerPickerPlaceholderCount: Int,
        nanoServices: PaymentsTransfersCorporateNanoServices
    ) -> PaymentsTransfersCorporateDomain.Binder {
        
        // MARK: - BannerPicker
        
        let standardNanoServicesComposer = StandardSelectedBannerDestinationNanoServicesComposer()
        let bannerPickerComposer = BannerPickerSectionBinderComposer(
            load: nanoServices.loadBanners,
            microServices: .init(
                showAll: { $1(BannerListModelStub(banners: $0)) },
                showBanner: selectBanner(composer: standardNanoServicesComposer)
            ),
            placeholderCount: bannerPickerPlaceholderCount,
            scheduler: schedulers.main
        )
        let bannerPicker = bannerPickerComposer.compose(
            prefix: [],
            suffix: (0..<6).map { _ in .placeholder(.init()) }
        )
        
        // MARK: - PaymentsTransfers
        
        let content = Domain.Content(
            bannerPicker: bannerPicker,
            reload: {
                
                bannerPicker.content.event(.load)
            }
        )
        
        return compose(
            getNavigation: getPaymentsTransfersCorporateNavigation,
            content: content,
            witnesses: witnesses()
        )
    }
    
    private func witnesses() -> Domain.Witnesses {
        
        return .init(
            emitting: { $0.eventPublisher },
            receiving: { $0.receiving }
        )
    }
}

// MARK: - Content

extension Domain.Content {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersCorporateSelect, Never> {
        
        bannerPicker.eventPublisher
    }
    
    func receiving() {
        
        bannerPicker.receiving()
    }
}

// MARK: - BannerPicker

extension PayHubUI.CorporateBannerPicker {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersCorporateSelect, Never> {
        
        bannerBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func receiving() {
        
        bannerBinder?.receiving()
    }
}

extension BannerPickerSectionBinder {
    
    var eventPublisher: AnyPublisher<PaymentsTransfersCorporateSelect, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func receiving() {
        
        content.event(.select(nil))
    }
}
