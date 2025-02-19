//
//  RootViewModelFactory+makeBannersBinder.swift
//  Vortex
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import Banners
import CombineSchedulers
import Foundation
import RemoteServices
import SerialComponents
import VortexTools


extension RootViewModelFactory {
    
    @inlinable
    func makeLoadBanners() -> LoadBanners {
        
        let bannersRemoteLoad = nanoServiceComposer.composeSerialResultLoad(
            createRequest: { try RequestFactory.createGetBannerCatalogListV2Request($0, 120.0) },
            mapResponse: Vortex.ResponseMapper.mapGetBannerCatalogListResponse
        )
        let (_, reload) = composeLoaders(
            remoteLoad: bannersRemoteLoad,
            fromModel: { $0 },
            toModel: { $0 }
        )
            
        return { completion in reload { completion(($0 ?? []).map { .banner($0) }) }}
    }
}

extension BannersBinder {
    
    static let preview: BannersBinder = RootViewModelFactory(
        model: .emptyMock,
        httpClient: Model.emptyMock.authenticatedHTTPClient(),
        logger: LoggerAgent(),
        mapScanResult: { _, completion in completion(.unknown) },
        makeQRResolve: { _ in { _ in .unknown }},
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

// MARK: - Adapters

extension Vortex.ResponseMapper {
    
    static func mapGetBannerCatalogListResponse(
        data: Data,
        response: HTTPURLResponse
    ) -> Result<SerialComponents.SerialStamped<String, [BannerCatalogListData]>, Error> {
        
        RemoteServices.ResponseMapper
            .mapGetBannerCatalogListResponse(data, response)
            .map {
                .init(
                    value: $0.bannerCatalogList.map {
                        .init($0)
                    }, serial: $0.serial)
            }
            .mapError { $0 }
    }
}
