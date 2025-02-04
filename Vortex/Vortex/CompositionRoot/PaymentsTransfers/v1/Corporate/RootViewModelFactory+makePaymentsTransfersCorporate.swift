//
//  RootViewModelFactory+makePaymentsTransfersCorporate.swift
//  Vortex
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
        featureFlags: FeatureFlags,
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
        
        // MARK: - CorporateTransfers
        
        let corporateTransfers = makeCorporateTransfers(featureFlags: featureFlags)
        
        // MARK: - PaymentsTransfers
        
        let content = Domain.Content(
            bannerPicker: bannerPicker,
            corporateTransfers: corporateTransfers,
            reload: { bannerPicker.content.event(.load) }
        )
        
        return composeBinder(
            content: content ,
            delayProvider: delayProvider,
            getNavigation: getPaymentsTransfersCorporateNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: PaymentsTransfersCorporateDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .main:        return .milliseconds(100)
        case .userAccount: return settings.delay
        }
    }
    
    @inlinable
    func emitting(
        content: PaymentsTransfersCorporateDomain.Content
    ) -> some Publisher<FlowEvent<PaymentsTransfersCorporateDomain.Select, Never>, Never> {
        
        Publishers.Merge(
            content.bannerPicker.eventPublisher,
            content.corporateTransfers.eventPublisher
        ).eraseToAnyPublisher()
    }
    
    @inlinable
    func dismissing(
        content: PaymentsTransfersCorporateDomain.Content
    ) -> () -> Void {
        
        return content.bannerPicker.dismissing
    }
}

// MARK: - BannerPicker

extension PayHubUI.CorporateBannerPicker {
    
    var eventPublisher: AnyPublisher<FlowEvent<PaymentsTransfersCorporateSelect, Never>, Never> {
        
        bannerBinder?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
    
    func dismissing() {
        
        bannerBinder?.dismissing()
    }
}

extension BannerPickerSectionBinder {
    
    var eventPublisher: AnyPublisher<FlowEvent<PaymentsTransfersCorporateSelect, Never>, Never> {
        
        flow.$state
            .compactMap { _ in return nil }
            .eraseToAnyPublisher()
    }
    
    func dismissing() {
        
        content.event(.select(nil))
    }
}

// MARK: - CorporateTransfers

extension CorporateTransfersProtocol {
    
    var eventPublisher: AnyPublisher<FlowEvent<PaymentsTransfersCorporateSelect, Never>, Never> {
        
        transfers?.eventPublisher ?? Empty().eraseToAnyPublisher()
    }
}

extension CorporateTransfersProtocol {
 
    var transfers: PaymentsTransfersCorporateTransfers? {
        
        self as? PaymentsTransfersCorporateTransfers
    }
}

extension PaymentsTransfersCorporateTransfers {
    
    var eventPublisher: AnyPublisher<FlowEvent<PaymentsTransfersCorporateSelect, Never>, Never> {
        
        openProduct.$state
            .compactMap {
                
                switch $0.navigation {
                case .main: return .select(.main)
                default:    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}
